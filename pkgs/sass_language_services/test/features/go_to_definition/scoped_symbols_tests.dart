import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/go_to_definition/scoped_symbols.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

ScopedSymbols getSymbols(TextDocument document) {
  var stylesheet = ls.parseStylesheet(document);
  var symbols = ScopedSymbols(stylesheet);
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

    test('at rules', () {
      var document = fs.createDocument('''
@font-face {
  font-family: "Vulf Mono", monospace;
}

@keyframes animation {

}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(2));

      var [first, second] = symbols.globalScope.children;
      expect(first.offset, equals(11));
      expect(first.length, equals(42));

      expect(second.offset, equals(76));
      expect(second.length, equals(4));
    });

    test('each rules', () {
      var document = fs.createDocument(r'''
@each $i in 1, 2, 3 {
  @debug $i;
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(1));

      var [first] = symbols.globalScope.children;
      expect(first.offset, equals(20));
      expect(first.length, equals(16));
    });

    test('for rules', () {
      var document = fs.createDocument(r'''
@for $i from 1 to 5 {
  .item-#{$i} {
    width: 2em * $i;
  }
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(1));

      var [first] = symbols.globalScope.children;
      expect(first.offset, equals(20));
      expect(first.length, equals(44));
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
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(1));

      var [first] = symbols.globalScope.children;
      expect(first.offset, equals(24));
      expect(first.length, equals(62));
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
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children.first.children, hasLength(2));

      var [first, second] = symbols.globalScope.children.first.children;
      expect(first.offset, equals(18));
      expect(first.length, equals(19));

      expect(second.offset, equals(44));
      expect(second.length, equals(20));
    });

    test('mixin rules', () {
      var document = fs.createDocument('''
@mixin large-text {
  font-size: 20px;
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(1));

      var [first] = symbols.globalScope.children;
      expect(first.offset, equals(18));
      expect(first.length, equals(22));
    });

    test('while rules', () {
      var document = fs.createDocument(r'''
@while $i < 0 {
  .item-#{$i} {
    width: 2em * $i;
  }
  $i: $i - 2;
}
''');
      var symbols = getSymbols(document);

      expect(symbols.globalScope.children, hasLength(1));

      var [first] = symbols.globalScope.children;
      expect(first.offset, equals(14));
      expect(first.length, equals(58));
    });
  });
}
