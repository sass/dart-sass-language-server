import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../range_matchers.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void main() {
  group('sass variables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('global in the same document', () async {
      var document = fs.createDocument(r'''
$b: blue

.a
  color: $b

''', uri: 'styles.sass');
      var result = await ls.goToDefinition(document, at(line: 3, char: 10));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(0));
      expect(result.range, EndsAtLine(0));
      expect(result.range, StartsAtCharacter(0));
      expect(result.range, EndsAtCharacter(2));

      expect(result.uri.toString(), endsWith('styles.sass'));
    });

    test('global in a different document', () async {
      fs.createDocument(r'$b: #000;', uri: 'colors.scss');
      fs.createDocument(r'$b: 800;', uri: 'weights.scss');

      var document = fs.createDocument(r'''
@use "colors";
@use "weights" as w;

.a {
  color: colors.$b;
  font-weight: w.$b;
}
''');
      var result = await ls.goToDefinition(document, at(line: 4, char: 17));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(0));
      expect(result.range, EndsAtLine(0));
      expect(result.range, StartsAtCharacter(0));
      expect(result.range, EndsAtCharacter(2));

      expect(result.uri.toString(), endsWith('colors.scss'));

      result = await ls.goToDefinition(document, at(line: 5, char: 18));
      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(0));
      expect(result.range, EndsAtLine(0));
      expect(result.range, StartsAtCharacter(0));
      expect(result.range, EndsAtCharacter(2));

      expect(result.uri.toString(), endsWith('weights.scss'));
    });

    test('scoped in the same document', () async {
      var document = fs.createDocument(r'''
.a
  $b: blue
  color: $b

''', uri: 'styles.sass');
      var result = await ls.goToDefinition(document, at(line: 2, char: 10));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(1));
      expect(result.range, EndsAtLine(01));
      expect(result.range, StartsAtCharacter(2));
      expect(result.range, EndsAtCharacter(4));

      expect(result.uri.toString(), endsWith('styles.sass'));
    });

    test('no scoped in a different document', () async {
      fs.createDocument(r'''
.a
  $b: blue
  color: $b
''', uri: 'links.sass');

      var document = fs.createDocument(r'''
@use "links";

.a {
  color: links.$b;
}
''');
      var result = await ls.goToDefinition(document, at(line: 3, char: 16));

      expect(result, isNull);
    });
  });

  group('mixins', () {
    setUp(() {
      ls.cache.clear();
    });

    test('in the same document', () async {
      var document = fs.createDocument(r'''
=reset-list
  margin: 0
  padding: 0
  list-style: none

=horizontal-list
  +reset-list

  li
    display: inline-block
    margin:
      left: -2px
      right: 2em

nav ul
  +horizontal-list

''', uri: 'styles.sass');
      var result = await ls.goToDefinition(document, at(line: 6, char: 4));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(0));
      expect(result.range, EndsAtLine(0));
      expect(result.range, StartsAtCharacter(1));
      expect(result.range, EndsAtCharacter(11));

      expect(result.uri.toString(), endsWith('styles.sass'));
    });

    test('in a different document', () async {
      fs.createDocument(r'''
=reset-list
  margin: 0
  padding: 0
  list-style: none

=horizontal-list
  +reset-list

  li
    display: inline-block
    margin:
      left: -2px
      right: 2em
''', uri: 'list.sass');

      var document = fs.createDocument(r'''
@use "list";

nav ul {
  @include list.horizontal-list;
}
''');
      var result = await ls.goToDefinition(document, at(line: 3, char: 12));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(5));
      expect(result.range, EndsAtLine(5));
      expect(result.range, StartsAtCharacter(1));
      expect(result.range, EndsAtCharacter(16));

      expect(result.uri.toString(), endsWith('list.sass'));
    });

    test('behind a prefix', () async {
      fs.createDocument(r'''
=reset-list
  margin: 0
  padding: 0
  list-style: none

=horizontal-list
  +reset-list

  li
    display: inline-block
    margin:
      left: -2px
      right: 2em
''', uri: '_list.sass');

      fs.createDocument(r'''
@forward "list" as list-*
''', uri: 'shared.sass');

      var document = fs.createDocument(r'''
@use "shared";

nav ul {
  @include shared.list-horizontal-list;
}
''');
      var result = await ls.goToDefinition(document, at(line: 3, char: 24));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(5));
      expect(result.range, EndsAtLine(5));
      expect(result.range, StartsAtCharacter(1));
      expect(result.range, EndsAtCharacter(16));

      expect(result.uri.toString(), endsWith('_list.sass'));
    });
  });

  group('sass functions', () {
    setUp(() {
      ls.cache.clear();
    });

    test('in the same document', () async {
      var document = fs.createDocument(r'''
@function multiply($a, $b)
  @return $a * $b

.a
  font-size: #{multiply(16, 1)}px
''', uri: 'styles.sass');
      var result = await ls.goToDefinition(document, at(line: 4, char: 16));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(0));
      expect(result.range, EndsAtLine(0));
      expect(result.range, StartsAtCharacter(10));
      expect(result.range, EndsAtCharacter(18));

      expect(result.uri.toString(), endsWith('styles.sass'));
    });

    test('in a different document', () async {
      fs.createDocument(r'''
@function multiply($a, $b)
  @return $a * $b
''', uri: '_utils.sass');

      var document = fs.createDocument(r'''
@use "utils"

.a
  font-size: #{utils.multiply(16, 1)}px
''', uri: 'styles.sass');
      var result = await ls.goToDefinition(document, at(line: 3, char: 22));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(0));
      expect(result.range, EndsAtLine(0));
      expect(result.range, StartsAtCharacter(10));
      expect(result.range, EndsAtCharacter(18));

      expect(result.uri.toString(), endsWith('_utils.sass'));
    });
  });

  group('css variables', () {
    setUp(() {
      ls.cache.clear();
    });
  });

  group('@extended CSS class', () {
    setUp(() {
      ls.cache.clear();
    });
  });

  group('@extended placeholder selector', () {
    setUp(() {
      ls.cache.clear();
    });
  });
}
