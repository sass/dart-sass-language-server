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

    test('finds global variable references', () async {
      var document = fs.createDocument(r'''
$b: blue
.a
  color: $b
''', uri: 'styles.sass');
      var result =
          await ls.findReferences(document, at(line: 2, char: 10), context);

      expect(result, hasLength(2));

      var [first, second] = result;
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(0));
      expect(first.range, EndsAtCharacter(2));

      expect(second.range, StartsAtLine(2));
      expect(second.range, EndsAtLine(2));
      expect(second.range, StartsAtCharacter(9));
      expect(second.range, EndsAtCharacter(11));
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

    test('finds references in maps', () async {
      var document = fs.createDocument(r'''
$message: "Hello, World!";

$map: (
  "var": $message,
);
''');

      var result =
          await ls.findReferences(document, at(line: 0, char: 1), context);

      expect(result, hasLength(2));

      var [first, second] = result;
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(0));
      expect(first.range, EndsAtCharacter(8));

      expect(second.range, StartsAtLine(3));
      expect(second.range, EndsAtLine(3));
      expect(second.range, StartsAtCharacter(9));
      expect(second.range, EndsAtCharacter(17));
    });
  });

  group('CSS variables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds references in the same document', () async {
      var document = fs.createDocument(r'''
:root {
  --color-text: #000;
}

body {
  color: var(--color-text);
}
''', uri: 'styles.css');

      var result =
          await ls.findReferences(document, at(line: 1, char: 5), context);

      expect(result, hasLength(2));

      var [first, second] = result;

      expect(first.range, StartsAtLine(1));
      expect(first.range, EndsAtLine(1));
      expect(first.range, StartsAtCharacter(2));
      expect(first.range, EndsAtCharacter(14));

      expect(second.range, StartsAtLine(5));
      expect(second.range, EndsAtLine(5));
      expect(second.range, StartsAtCharacter(13));
      expect(second.range, EndsAtCharacter(25));
    });

    test('finds references across workspace', () async {
      var root = fs.createDocument(r'''
:root {
  --color-text: #000;
}
''', uri: 'root.css');
      var styles = fs.createDocument(r'''
body {
  color: var(--color-text);
}
''', uri: 'styles.css');

      // Emulate the language server's initial scan.
      // Needed since the stylesheets don't all have eachother in their
      // module tree, but they all reference the same variable.
      ls.parseStylesheet(root);
      ls.parseStylesheet(styles);

      var result =
          await ls.findReferences(styles, at(line: 1, char: 16), context);

      expect(result, hasLength(2));

      var [first, second] = result;

      expect(first.uri.toString(), endsWith('root.css'));
      expect(first.range, StartsAtLine(1));
      expect(first.range, EndsAtLine(1));
      expect(first.range, StartsAtCharacter(2));
      expect(first.range, EndsAtCharacter(14));

      expect(second.uri.toString(), endsWith('styles.css'));
      expect(second.range, StartsAtLine(1));
      expect(second.range, EndsAtLine(1));
      expect(second.range, StartsAtCharacter(13));
      expect(second.range, EndsAtCharacter(25));
    });
  });

  group('sass functions', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds global references', () async {
      var document = fs.createDocument(r'''
@function hello()
  @return "world"

.a::after
  content: hello()
''', uri: 'styles.sass');
      var result =
          await ls.findReferences(document, at(line: 0, char: 11), context);

      expect(result, hasLength(2));

      var [first, second] = result;
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(10));
      expect(first.range, EndsAtCharacter(15));

      expect(second.range, StartsAtLine(4));
      expect(second.range, EndsAtLine(4));
      expect(second.range, StartsAtCharacter(11));
      expect(second.range, EndsAtCharacter(16));
    });

    test('finds references across workspace', () async {
      fs.createDocument(r'''
@function hello()
  @return "world"
''', uri: 'shared.sass');
      var document = fs.createDocument(r'''
@use "shared"

.a::after
  content: shared.hello()
''', uri: 'styles.sass');
      var result =
          await ls.findReferences(document, at(line: 3, char: 19), context);

      expect(result, hasLength(2));

      var [first, second] = result;

      expect(first.uri.toString(), endsWith('styles.sass'));
      expect(first.range, StartsAtLine(3));
      expect(first.range, EndsAtLine(3));
      expect(first.range, StartsAtCharacter(18));
      expect(first.range, EndsAtCharacter(23));

      expect(second.uri.toString(), endsWith('shared.sass'));
      expect(second.range, StartsAtLine(0));
      expect(second.range, EndsAtLine(0));
      expect(second.range, StartsAtCharacter(10));
      expect(second.range, EndsAtCharacter(15));
    });

    test('finds references in visibility modifier', () async {
      fs.createDocument(r'''
@function hello()
  @return "world"
''', uri: 'shared.sass');
      var document = fs.createDocument(r'''
@forward "shared" hide hello;
''', uri: 'styles.scss');
      var result =
          await ls.findReferences(document, at(line: 0, char: 24), context);

      expect(result, hasLength(2));

      var [first, second] = result;

      expect(first.uri.toString(), endsWith('styles.scss'));
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(23));
      expect(first.range, EndsAtCharacter(28));

      expect(second.uri.toString(), endsWith('shared.sass'));
      expect(second.range, StartsAtLine(0));
      expect(second.range, EndsAtLine(0));
      expect(second.range, StartsAtCharacter(10));
      expect(second.range, EndsAtCharacter(15));
    });

    test('finds references in maps', () async {
      var document = fs.createDocument(r'''
@function hello() {
  @return "world";
}

$map: (
  "fun": hello(),
);
''');

      var result =
          await ls.findReferences(document, at(line: 0, char: 11), context);

      expect(result, hasLength(2));

      var [first, second] = result;
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(10));
      expect(first.range, EndsAtCharacter(15));

      expect(second.range, StartsAtLine(5));
      expect(second.range, EndsAtLine(5));
      expect(second.range, StartsAtCharacter(9));
      expect(second.range, EndsAtCharacter(14));
    });
  });

  group('sass mixins', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds global references', () async {
      var document = fs.createDocument(r'''
@mixin hello()
  content: 'hello'

.a::after
  @include hello
''', uri: 'styles.sass');
      var result =
          await ls.findReferences(document, at(line: 0, char: 8), context);

      expect(result, hasLength(2));

      var [first, second] = result;
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(7));
      expect(first.range, EndsAtCharacter(12));

      expect(second.range, StartsAtLine(4));
      expect(second.range, EndsAtLine(4));
      expect(second.range, StartsAtCharacter(11));
      expect(second.range, EndsAtCharacter(16));
    });

    test('finds references across workspace', () async {
      fs.createDocument(r'''
@mixin hello()
  content: 'hello'
''', uri: 'shared.sass');
      var document = fs.createDocument(r'''
@use "shared"

.a::after
  @include shared.hello()
''', uri: 'styles.sass');
      var result =
          await ls.findReferences(document, at(line: 3, char: 19), context);

      expect(result, hasLength(2));

      var [first, second] = result;

      expect(first.uri.toString(), endsWith('styles.sass'));
      expect(first.range, StartsAtLine(3));
      expect(first.range, EndsAtLine(3));
      expect(first.range, StartsAtCharacter(18));
      expect(first.range, EndsAtCharacter(23));

      expect(second.uri.toString(), endsWith('shared.sass'));
      expect(second.range, StartsAtLine(0));
      expect(second.range, EndsAtLine(0));
      expect(second.range, StartsAtCharacter(7));
      expect(second.range, EndsAtCharacter(12));
    });

    test('finds references in visibility modifier', () async {
      fs.createDocument(r'''
@mixin hello()
  content: 'hello'
''', uri: 'shared.sass');
      var document = fs.createDocument(r'''
@forward "shared" hide hello;
''', uri: 'styles.scss');
      var result =
          await ls.findReferences(document, at(line: 0, char: 24), context);

      expect(result, hasLength(2));

      var [first, second] = result;

      expect(first.uri.toString(), endsWith('styles.scss'));
      expect(first.range, StartsAtLine(0));
      expect(first.range, EndsAtLine(0));
      expect(first.range, StartsAtCharacter(23));
      expect(first.range, EndsAtCharacter(28));

      expect(second.uri.toString(), endsWith('shared.sass'));
      expect(second.range, StartsAtLine(0));
      expect(second.range, EndsAtLine(0));
      expect(second.range, StartsAtCharacter(7));
      expect(second.range, EndsAtCharacter(12));
    });
  });

  group('placeholder selectors', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds placeholder selectors', () async {
      fs.createDocument(r'''
%theme {
  color: var(--color-text);
}
''', uri: '_place.scss');
      var document = fs.createDocument(r'''
@use "place";

.a {
  @extend %theme;
}
''', uri: 'styles.scss');

      var result =
          await ls.findReferences(document, at(line: 3, char: 12), context);

      var [first, second] = result;

      expect(first.uri.toString(), endsWith('styles.scss'));
      expect(first.range, StartsAtLine(3));
      expect(first.range, EndsAtLine(3));
      expect(first.range, StartsAtCharacter(10));
      expect(first.range, EndsAtCharacter(16));

      expect(second.uri.toString(), endsWith('_place.scss'));

      expect(second.range, StartsAtLine(0));
      expect(second.range, EndsAtLine(0));
      expect(second.range, StartsAtCharacter(0));
      expect(second.range, EndsAtCharacter(6));
    });
  });

  group('sass built-in modules', () {
    setUp(() {
      ls.cache.clear();
    });

    test('finds sass built-in modules', () async {
      var particle = fs.createDocument(r'''
@use "sass:color";

$_color: color.scale($color: "#1b1917", $alpha: -75%);

.a {
  color: $_color;
  transform: scale(1.1); // Does not confuse color.scale for the transform function
}
''', uri: 'particle.scss');
      var wave = fs.createDocument(r'''
@use "sass:color";

$_other: color.scale($color: "#1b1917", $alpha: -75%);
''', uri: 'wave.scss');

      // Emulate the language server's initial scan.
      // Needed since the stylesheets don't all have eachother in their
      // module tree, but they all reference the same variable.
      ls.parseStylesheet(particle);
      ls.parseStylesheet(wave);

      var result =
          await ls.findReferences(wave, at(line: 2, char: 16), context);

      expect(result, hasLength(2));
    });
  });
}
