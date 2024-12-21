import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

String? getContents(lsp.Hover? hover) {
  if (hover == null) return null;

  var result = hover.contents.map((v) => v, (v) => v);
  if (result is lsp.MarkupContent) {
    return result.value;
  } else {
    return result as String;
  }
}

void main() {
  group('CSS selectors', () {
    setUp(() {
      ls.cache.clear();
    });

    test('nested element selector', () async {
      var document = fs.createDocument(r'''
nav {
    ul {
        margin: 0;
        padding: 0;
        list-style: none;
    }

    li {
        display: inline-block;
    }

    a {
        display: block;
        padding: 6px 12px;
        text-decoration: none;
    }
}
''');
      var result = await ls.hover(document, at(line: 1, char: 5));

      expect(result, isNotNull);
      expect(getContents(result), contains('nav ul'));
      expect(getContents(result), contains('0, 0, 2'));
    });

    test(':has(.foo)', () async {
      var document = fs.createDocument(r'''
:has(.foo) {
  margin: 0;
  padding: 0;
}
''');
      var result = await ls.hover(document, at(line: 0, char: 2));

      expect(result, isNotNull);
      expect(getContents(result), contains(':has(.foo)'));
      expect(getContents(result), contains('0, 1, 0'));
    });

    test(':has(#bar)', () async {
      var document = fs.createDocument(r'''
:has(#bar) {
  margin: 0;
  padding: 0;
}
''');
      var result = await ls.hover(document, at(line: 0, char: 2));

      expect(result, isNotNull);
      expect(getContents(result), contains(':has(#bar)'));
      expect(getContents(result), contains('1, 0, 0'));
    });
  });

  group('CSS properties', () {
    setUp(() {
      ls.cache.clear();
    });

    test('property', () async {
      var document = fs.createDocument(r'''
#bar {
  margin: 0;
  padding: 0;
}
''');
      var result = await ls.hover(document, at(line: 1, char: 3));

      expect(result, isNotNull);
      expect(getContents(result), contains('margin'));
    });
  });

  group('Parent selectors', () {
    setUp(() {
      ls.cache.clear();
    });

    test('simple parent selector', () async {
      var document = fs.createDocument(r'''
.button {
    &--primary {
        margin: 0;
        padding: 0;
    }
}
''');
      var result = await ls.hover(document, at(line: 1, char: 5));

      expect(result, isNotNull);
      expect(getContents(result), contains('.button--primary'));
      expect(getContents(result), contains('0, 1, 0'));
    });

    test('parent selector with extras', () async {
      var document = fs.createDocument(r'''
.button {
  &--primary {
    &::hover {
        margin: 0;
        padding: 0;
    }
  }
}
''');
      var result = await ls.hover(document, at(line: 2, char: 10));

      expect(result, isNotNull);
      expect(getContents(result), contains('.button--primary::hover'));
      expect(getContents(result), contains('0, 1, 1'));
    });

    test('nested parent selector with extras', () async {
      var document = fs.createDocument(r'''
.button {
  &--primary::hover {
    margin: 0;
    padding: 0;

    .icon {
      &--outline {
        fill: #000;
      }
    }
  }
}
''');
      var result = await ls.hover(document, at(line: 6, char: 10));

      expect(result, isNotNull);
      expect(getContents(result),
          contains('.button--primary::hover .icon--outline'));
      expect(getContents(result), contains('0, 2, 1'));
    });

    test('parent selector not at the beginning of a selector', () async {
      var document = fs.createDocument(r'''
.button {
  &--primary,
  &--secondary {
    html[data-touch] &.button--pressed::before {
      animation: fancy;
    }
  }
}
''');

      var result = await ls.hover(document, at(line: 3, char: 24));

      expect(result, isNotNull);
      expect(
          getContents(result),
          contains(
              'html[data-touch] .button--primary.button--pressed::before'));
      expect(getContents(result), contains('0, 3, 2'));
    });
  });

  group('Sass variables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('global variable with function expression value', () async {
      var document = fs.createDocument(r'''
$_button-border-width: rem(1px);

.button {
  border-width: $_button-border-width;
}
''');

      var result = await ls.hover(document, at(line: 3, char: 23));

      expect(result, isNotNull);
      expect(getContents(result), contains(r'$_button-border-width: rem(1px)'));
    });

    test('variable behind a forward prefix', () async {
      fs.createDocument(r'''
$border-width: rem(1px);
''', uri: 'button.scss');

      fs.createDocument(r'''
@forward "button" as button-*;
''', uri: 'core.scss');

      var document = fs.createDocument(r'''
@use "core";

.button {
  border-width: core.$button-border-width;
}
''');

      var result = await ls.hover(document, at(line: 3, char: 23));

      expect(result, isNotNull);
      expect(getContents(result), contains(r'$button-border-width: rem(1px)'));
    });
  });

  group('Sass functions', () {
    setUp(() {
      ls.cache.clear();
    });

    test('function with no arguments', () async {
      var document = fs.createDocument(r'''
@function getPrimary() {
  @return limegreen;
}

.a {
  color: getPrimary();
}
''');

      var result = await ls.hover(document, at(line: 5, char: 14));

      expect(result, isNotNull);
      expect(getContents(result), contains(r'@function getPrimary()'));
    });

    test('function with arguments', () async {
      var document = fs.createDocument(r'''
@function compare($a: 1, $b) {
  @return $a > $b;
}

@debug compare($b: 2);
''');

      var result = await ls.hover(document, at(line: 4, char: 9));

      expect(result, isNotNull);
      expect(getContents(result), contains(r'@function compare($a: 1, $b)'));
    });

    test('function from a different module', () async {
      fs.createDocument(r'''
@function compare($a: 1, $b) {
  @return $a > $b;
}
''', uri: 'core.scss');

      var document = fs.createDocument(r'''
@use "core";

@debug core.compare($b: 2);
''');

      var result = await ls.hover(document, at(line: 2, char: 9));

      expect(result, isNotNull);
      expect(getContents(result), contains(r'@function compare($a: 1, $b)'));
    });

    test('function behind a prefix', () async {
      fs.createDocument(r'''
@function compare($a: 1, $b) {
  @return $a > $b;
}
''', uri: 'math.scss');

      fs.createDocument(r'''
@forward "math" as math-*;
''', uri: 'core.scss');

      var document = fs.createDocument(r'''
@use "core";

@debug core.math-compare($b: 2);
''');

      var result = await ls.hover(document, at(line: 2, char: 19));

      expect(result, isNotNull);
      expect(
          getContents(result), contains(r'@function math-compare($a: 1, $b)'));
    });
  });

  group('Sass mixins', () {
    setUp(() {
      ls.cache.clear();
    });

    test('mixin with no arguments', () async {
      var document = fs.createDocument(r'''
@mixin primary {
  color: green;
}

.a {
  @include primary;
}
''');

      var result = await ls.hover(document, at(line: 5, char: 14));

      expect(result, isNotNull);
      expect(getContents(result), contains(r'@mixin primary'));
    });

    test('mixin with arguments', () async {
      var document = fs.createDocument(r'''
@mixin theme($base: green) {
  color: green;
}

.a {
  @include theme;
}
''');

      var result = await ls.hover(document, at(line: 5, char: 14));

      expect(result, isNotNull);
      expect(getContents(result), contains(r'@mixin theme($base: green)'));
    });

    test('mixin from a different module', () async {
      fs.createDocument(r'''
@mixin theme($base: green) {
  color: green;
}
''', uri: 'core.scss');

      var document = fs.createDocument(r'''
@use "core";

.a {
  @include core.theme;
}
''');

      var result = await ls.hover(document, at(line: 3, char: 19));

      expect(result, isNotNull);
      expect(getContents(result), contains(r'@mixin theme($base: green)'));
    });

    test('mixin behind a prefix', () async {
      fs.createDocument(r'''
@mixin color($base: green) {
  color: green;
}
''', uri: 'theme.scss');

      fs.createDocument(r'''
@forward "theme" as theme-*;
''', uri: 'core.scss');

      var document = fs.createDocument(r'''
@use "core";

.a {
  @include core.theme-color;
}
''');

      var result = await ls.hover(document, at(line: 3, char: 19));

      expect(result, isNotNull);
      expect(
          getContents(result), contains(r'@mixin theme-color($base: green)'));
    });
  });

  group('Sass built-ins', () {
    setUp(() {
      ls.cache.clear();
    });

    test('math variable', () async {
      var document = fs.createDocument(r'''
@use "sass:math";

@debug math.$pi;
''');

      var result = await ls.hover(document, at(line: 2, char: 14));
      expect(result, isNotNull);
      expect(getContents(result), contains('π'));
      expect(getContents(result), contains('sass-lang.com'));
    });

    test('math function', () async {
      var document = fs.createDocument(r'''
@use "sass:math";

@debug math.ceil(4);
''');

      var result = await ls.hover(document, at(line: 2, char: 14));
      expect(result, isNotNull);
      expect(getContents(result),
          contains('Rounds up to the nearest whole number'));
      expect(getContents(result), contains('sass-lang.com'));
    });

    test('function as variable expression', () async {
      var document = fs.createDocument(r'''
@use "sass:string";

$_id: string.unique-id();
''');

      var result = await ls.hover(document, at(line: 2, char: 14));
      expect(result, isNotNull);
      expect(getContents(result),
          contains('Returns a randomly-generated unquoted string'));
      expect(getContents(result), contains('sass-lang.com'));
    });
  });
}
