import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/go_to_definition/scope_visitor.dart';
import 'package:sass_language_services/src/features/go_to_definition/scoped_symbols.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

ScopedSymbols getSymbols(TextDocument document) {
  var stylesheet = ls.parseStylesheet(document);
  var symbols = ScopedSymbols(stylesheet,
      document.languageId == 'sass' ? Dialect.indented : Dialect.scss);
  return symbols;
}

void main() {
  group('SCSS scope building', () {
    setUp(() {
      ls.cache.clear();
    });

    test('style rules', () {
      var document = fs.createDocument('''
.foo {
  color: red;
}

.bar {
  color: blue;
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(2));

      var [first, second] = symbols.globalScope.children;
      expect(first.offset, equals(5));
      expect(first.length, equals(17));

      expect(second.offset, equals(29));
      expect(second.length, equals(18));
    });

    test('each rules', () {
      var document = fs.createDocument(r'''
@each $i in 1, 2, 3 {
  @debug $i;
}

@each $y in 3, 2, 1 {
  @debug $y;
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(2));

      var [first, second] = symbols.globalScope.children;
      expect(first.offset, equals(20));
      expect(first.length, equals(16));

      expect(second.offset, equals(58));
      expect(second.length, equals(16));
    });

    test('for rules', () {
      var document = fs.createDocument(r'''
@for $i from 1 to 5 {
  .item-#{$i} {
    width: 2em * $i;
  }
}

@for $y from 5 to 10 {
  .item-#{$y} {
    width: 1em * $y;
  }
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(2));

      var [first, second] = symbols.globalScope.children;
      expect(first.offset, equals(20));
      expect(first.length, equals(44));

      expect(second.offset, equals(87));
      expect(second.length, equals(44));
    });

    test('function rules', () {
      var document = fs.createDocument(r'''
@function is-even($int) {
  @if $int % 2 == 0 {
    @return true;
  } @else {
    @return false;
  }
}

@function is-odd($int) {
  @if $int % 2 != 0 {
    @return true;
  } @else {
    @return false;
  }
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(2));

      var [first, second] = symbols.globalScope.children;
      expect(first.offset, equals(24));
      expect(first.length, equals(78));

      expect(second.offset, equals(127));
      expect(second.length, equals(78));
    });

    test('if else rules', () {
      var document = fs.createDocument(r'''
@function is-even($int) {
  @if $int % 2 == 0 {
    @return true;
  } @else {
    @return false;
  }
}

@function is-odd($int) {
  @if $int % 2 != 0 {
    @return true;
  } @else {
    @return false;
  }
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(2));
      expect(symbols.globalScope.children.first.children, hasLength(2));

      var [first, second] = symbols.globalScope.children.first.children;
      expect(first.offset, equals(46));
      expect(first.length, equals(23));

      expect(second.offset, equals(76));
      expect(second.length, equals(24));

      var [third, fourth] = symbols.globalScope.children.last.children;
      expect(third.offset, equals(149));
      expect(third.length, equals(23));

      expect(fourth.offset, equals(179));
      expect(fourth.length, equals(24));
    });

    test('if rule with multiple child nodes', () {
      var document = fs.createDocument(r'''
@mixin _single-spacing($spacing-step, $position) {
    @if $position and list.index($positions, $position) {
        // Add dash before position to ease interpolation
        $position: "-#{$position}";
    }

    @if map.has-key($spacing, $spacing-step) {
        margin#{$position}: map.get($spacing, $spacing-step);
    } @else {
        @error "Could not find \"#{$spacing-step}\" in the list of spacing values";
    }
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(1));
      expect(symbols.globalScope.children.first.children, hasLength(3));

      var [first, second, third] = symbols.globalScope.children.first.children;

      expect(first.offset, equals(107));
      expect(first.length, equals(101));

      expect(second.offset, equals(255));
      expect(second.length, equals(69));

      expect(third.offset, equals(331));
      expect(third.length, equals(91));
    });

    test('mixin rules', () {
      var document = fs.createDocument('''
@mixin large-text {
  font-size: 20px;
}

@mixin small-text {
  font-size: 12px;
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(2));

      var [first, second] = symbols.globalScope.children;
      expect(first.offset, equals(18));
      expect(first.length, equals(22));

      expect(second.offset, equals(60));
      expect(second.length, equals(22));
    });

    test('while rules', () {
      var document = fs.createDocument(r'''
@while $i < 0 {
  .item-#{$i} {
    width: 2em * $i;
  }
  $i: $i - 2;
}

@while $y < 0 {
  .item-#{$y} {
    width: 1em * $y;
  }
  $y: $y - 1;
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(2));

      var [first, second] = symbols.globalScope.children;
      expect(first.offset, equals(14));
      expect(first.length, equals(58));

      expect(second.offset, equals(88));
      expect(second.length, equals(58));
    });
  });
}
