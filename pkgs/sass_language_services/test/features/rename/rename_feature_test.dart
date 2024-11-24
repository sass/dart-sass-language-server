import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../range_matchers.dart';
import '../../test_client_capabilities.dart';

void main() {
  group('prepare rename', () {
    final fs = MemoryFileSystem();
    final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

    setUp(() {
      ls.cache.clear();
    });

    test(r'excludes the $ of a variable from the rename', () async {
      fs.createDocument(r'''
$day: "monday";
''', uri: 'ki.scss');
      var document = fs.createDocument(r'''
@use "ki";

.a::after {
  content: ki.$day;
}
''');
      var response = await ls.prepareRename(document, at(line: 3, char: 16));
      var result = response.map((v) => v, (v) => v, (v) => v);
      if (result is lsp.PlaceholderAndRange) {
        expect(result.range, StartsAtLine(3));
        expect(result.range, EndsAtLine(3));
        expect(result.range, StartsAtCharacter(15));
        expect(result.range, EndsAtCharacter(18));

        expect(result.placeholder, equals('day'));
      } else {
        fail('Expected type PlaceholderAndRange');
      }
    });

    test('excludes the % of a placeholder from the rename', () async {
      fs.createDocument(r'''
%box {
  color: blue;
}
''', uri: 'ki.scss');
      var document = fs.createDocument(r'''
@use "ki";

.alert {
  @extend %box;
}
''');
      var response = await ls.prepareRename(document, at(line: 3, char: 12));
      var result = response.map((v) => v, (v) => v, (v) => v);
      if (result is lsp.PlaceholderAndRange) {
        expect(result.range, StartsAtLine(3));
        expect(result.range, EndsAtLine(3));
        expect(result.range, StartsAtCharacter(11));
        expect(result.range, EndsAtCharacter(14));

        expect(result.placeholder, equals('box'));
      } else {
        fail('Expected type PlaceholderAndRange');
      }
    });

    test('excludes forward prefix from the rename', () async {
      fs.createDocument(r'''
$color-primary: purple
''', uri: '_brand.sass');
      fs.createDocument(r'''
@forward 'brand' as brand-* show $color-primary
''', uri: '_theme.sass');
      var document = fs.createDocument(r'''
@use 'theme';

.a {
  color: theme.$brand-color-primary;
}
''');

      var response = await ls.prepareRename(document, at(line: 3, char: 20));
      var result = response.map((v) => v, (v) => v, (v) => v);
      if (result is lsp.PlaceholderAndRange) {
        expect(result.range, StartsAtLine(3));
        expect(result.range, EndsAtLine(3));
        expect(result.range, StartsAtCharacter(22));
        expect(result.range, EndsAtCharacter(35));

        expect(result.placeholder, equals('color-primary'));
      } else {
        fail('Expected type PlaceholderAndRange');
      }
    });

    test('rename range is the selection range, not symbol range', () async {
      var document = fs.createDocument(r'''
@mixin mixin1 {
  $value: 1;
  line-height: $value;
}

.a {
  @include mixin1;
}
''');
      var response = await ls.prepareRename(document, at(line: 6, char: 12));
      var result = response.map((v) => v, (v) => v, (v) => v);
      if (result is lsp.PlaceholderAndRange) {
        expect(result.range, StartsAtLine(6));
        expect(result.range, EndsAtLine(6));
        expect(result.range, StartsAtCharacter(11));
        expect(result.range, EndsAtCharacter(17));

        expect(result.placeholder, equals('mixin1'));
      } else {
        fail('Expected type PlaceholderAndRange');
      }
    });
  });

  group('rename', () {
    final fs = MemoryFileSystem();
    final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

    setUp(() {
      ls.cache.clear();
    });

    test('renames variable across workspace', () async {
      fs.createDocument(r'''
$day: 'monday'
''', uri: '_ki.sass');

      var document = fs.createDocument(r'''
@use 'ki';

.a::after {
  content: ki.$day;
}
''', uri: 'helen.scss');

      var response = await ls.prepareRename(document, at(line: 3, char: 17));
      var preparation = response.map((v) => v, (v) => v, (v) => v);
      if (preparation is lsp.PlaceholderAndRange) {
        var rename = await ls.rename(document, preparation.range.start, 'gato');
        expect(rename.changes, hasLength(2));

        var [first, second] = rename.changes!.entries.toList();
        expect(first.key.toString(), endsWith('helen.scss'));
        expect(first.value, hasLength(1));
        expect(first.value.first.newText, equals('gato'));
        expect(first.value.first.range, StartsAtLine(3));
        expect(first.value.first.range, EndsAtLine(3));
        expect(first.value.first.range, StartsAtCharacter(15));
        expect(first.value.first.range, EndsAtCharacter(18));

        expect(second.key.toString(), endsWith('_ki.sass'));
        expect(second.value, hasLength(1));
        expect(second.value.first.newText, equals('gato'));
        expect(second.value.first.range, StartsAtLine(0));
        expect(second.value.first.range, EndsAtLine(0));
        expect(second.value.first.range, StartsAtCharacter(1));
        expect(second.value.first.range, EndsAtCharacter(4));
      } else {
        fail('Expected type PlaceholderAndRange');
      }
    });

    test('renames prefixed function across workspace', () async {
      fs.createDocument(r'''
@function hello()
  @return 'world'
''', uri: '_ki.sass');

      fs.createDocument(r'''
@forward 'ki' as ki-* show hello;
''', uri: '_dev.scss');

      var document = fs.createDocument(r'''
@use 'dev';

.a::after {
  content: dev.ki-hello();
}
''', uri: 'helen.scss');

      var response = await ls.prepareRename(document, at(line: 3, char: 17));
      var preparation = response.map((v) => v, (v) => v, (v) => v);
      if (preparation is lsp.PlaceholderAndRange) {
        var rename = await ls.rename(document, preparation.range.start, 'hola');
        expect(rename.changes, hasLength(3));

        var [first, second, third] = rename.changes!.entries.toList();
        expect(first.key.toString(), endsWith('helen.scss'));
        expect(first.value, hasLength(1));
        expect(first.value.first.newText, equals('hola'));
        expect(first.value.first.range, StartsAtLine(3));
        expect(first.value.first.range, EndsAtLine(3));
        expect(first.value.first.range, StartsAtCharacter(18));
        expect(first.value.first.range, EndsAtCharacter(23));

        expect(second.key.toString(), endsWith('_dev.scss'));
        expect(second.value, hasLength(1));
        expect(second.value.first.newText, equals('hola'));
        expect(second.value.first.range, StartsAtLine(0));
        expect(second.value.first.range, EndsAtLine(0));
        expect(second.value.first.range, StartsAtCharacter(27));
        expect(second.value.first.range, EndsAtCharacter(32));

        expect(third.key.toString(), endsWith('_ki.sass'));
        expect(third.value, hasLength(1));
        expect(third.value.first.newText, equals('hola'));
        expect(third.value.first.range, StartsAtLine(0));
        expect(third.value.first.range, EndsAtLine(0));
        expect(third.value.first.range, StartsAtCharacter(10));
        expect(third.value.first.range, EndsAtCharacter(15));
      } else {
        fail('Expected type PlaceholderAndRange');
      }
    });
  });
}
