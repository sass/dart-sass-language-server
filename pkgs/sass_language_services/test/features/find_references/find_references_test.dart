import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../range_matchers.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());
final context = lsp.ReferenceContext(includeDeclaration: true);

void main() {
  group('sass variables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds variable references in scope', () async {
      var document = fs.createDocument(r'''
.a
  $b: blue
  color: $b
''', uri: 'styles.sass');
      var result =
          await ls.findReferences(document, at(line: 2, char: 10), context);

      expect(result, hasLength(2));

      var [first, second] = result;
      expect(first.range, StartsAtLine(1));
      expect(first.range, EndsAtLine(1));
      expect(first.range, StartsAtCharacter(2));
      expect(first.range, EndsAtCharacter(4));

      expect(second.range, StartsAtLine(2));
      expect(second.range, EndsAtLine(2));
      expect(second.range, StartsAtCharacter(9));
      expect(second.range, EndsAtCharacter(11));
    });

    test('exclude declaration at user request', () async {
      var document = fs.createDocument(r'''
.a
  $b: blue
  color: $b
''', uri: 'styles.sass');
      var result = await ls.findReferences(
        document,
        at(line: 2, char: 10),
        lsp.ReferenceContext(includeDeclaration: false),
      );

      expect(result, hasLength(1));

      var [first] = result;
      expect(first.range, StartsAtLine(2));
      expect(first.range, EndsAtLine(2));
      expect(first.range, StartsAtCharacter(9));
      expect(first.range, EndsAtCharacter(11));
    });

    test('finds variable references across workspace', () async {
      var ki = fs.createDocument(r'''
$day: "monday";
''', uri: 'ki.scss');

      var helen = fs.createDocument(r'''
@use "ki";

.a::after {
  content: ki.$day;
}
''', uri: 'helen.scss');

      var document = fs.createDocument(r'''
@use "ki"

.a::before
  // Here it comes!
  content: ki.$day
''', uri: 'gato.sass');

      // Emulate the language server's initial scan.
      // Needed since gato does not have helen in its
      // module tree, but they both reference the same
      // variable.
      ls.parseStylesheet(ki);
      ls.parseStylesheet(helen);

      var result =
          await ls.findReferences(document, at(line: 4, char: 16), context);

      expect(result, hasLength(3));

      var [first, second, third] = result;
      expect(first.uri.toString(), endsWith('ki.scss'));
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(0));
      expect(first.range, EndsAtCharacter(4));

      expect(second.uri.toString(), endsWith('helen.scss'));
      expect(second.range, StartsAtLine(3));
      expect(second.range, EndsAtLine(3));
      expect(second.range, StartsAtCharacter(14));
      expect(second.range, EndsAtCharacter(18));

      expect(third.uri.toString(), endsWith('gato.sass'));
      expect(third.range, StartsAtLine(4));
      expect(third.range, EndsAtLine(4));
      expect(third.range, StartsAtCharacter(14));
      expect(third.range, EndsAtCharacter(18));
    });

    test('finds variable with prefix and in visibility modifier', () async {
      var ki = fs.createDocument(r'''
$day: "monday";
''', uri: 'ki.scss');
      var dev = fs.createDocument(r'''
@forward "ki" as ki-* show $day;
''', uri: 'dev.scss');

      var helen = fs.createDocument(r'''
@use "dev";

.a::after {
  content: dev.$ki-day;
}
''', uri: 'helen.scss');
      var gato = fs.createDocument(r'''
@use "ki";

.a::before {
  content: ki.$day;
}
''', uri: 'gato.scss');

      // Emulate the language server's initial scan.
      // Needed since the stylesheets don't all have eachother in their
      // module tree, but they all reference the same variable.
      ls.parseStylesheet(ki);
      ls.parseStylesheet(dev);
      ls.parseStylesheet(helen);

      var result =
          await ls.findReferences(gato, at(line: 3, char: 15), context);

      expect(result, hasLength(4));

      var [first, second, third, fourth] = result;
      expect(first.uri.toString(), endsWith('ki.scss'));
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(0));
      expect(first.range, EndsAtCharacter(4));

      expect(second.uri.toString(), endsWith('dev.scss'));
      expect(second.range, StartsAtLine(0));
      expect(second.range, EndsAtLine(0));
      expect(second.range, StartsAtCharacter(27));
      expect(second.range, EndsAtCharacter(31));

      expect(third.uri.toString(), endsWith('helen.scss'));
      expect(third.range, StartsAtLine(3));
      expect(third.range, EndsAtLine(3));
      expect(third.range, StartsAtCharacter(15));
      expect(third.range, EndsAtCharacter(22));

      expect(fourth.uri.toString(), endsWith('gato.scss'));
      expect(fourth.range, StartsAtLine(3));
      expect(fourth.range, EndsAtLine(3));
      expect(fourth.range, StartsAtCharacter(14));
      expect(fourth.range, EndsAtCharacter(18));
    });

    test('finds variables in maps', () async {
      // TODO
    });
  });

  group('CSS variables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds references in the same document', () async {
      // TODO
    });

    test('finds references across workspace', () async {
      // TODO
    });
  });

  group('sass functions', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds references in the same document', () async {
      // TODO
    });

    test('finds references across workspace', () async {
      // TODO
    });

    test('finds references in visibility modifier', () async {
      // TODO
    });

    test('finds references in visibility map', () async {
      // TODO
    });
  });

  group('sass mixins', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds references in the same document', () async {
      // TODO
    });

    test('finds references across workspace', () async {
      // TODO
    });

    test('finds references in visibility modifier', () async {
      // TODO
    });
  });

  group('sass mixins', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds placeholder selectors', () async {
      // TODO: test with declaration and @extend usage.
    });
  });

  group('placeholder selectors', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds placeholder selectors', () async {
      // TODO: test with declaration and @extend usage.
    });
  });

  group('sass built-in modules', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds sass built-in modules', () async {
      // TODO
    });
  });
}
