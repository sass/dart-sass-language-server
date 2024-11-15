import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../range_matchers.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void main() {
  group('selectors', () {
    setUp(() {
      ls.cache.clear();
    });

    test('CSS selector ranges are correct', () {
      var document = fs.createDocument('''
.foo {
  color: red;
}

.bar {
  color: blue;
}
''');

      var result = ls.findDocumentSymbols(document);
      var fooNameRange = result.first.selectionRange;
      var fooSymbolRange = result.first.range;
      expect(fooNameRange, StartsAtLine(0));
      expect(fooNameRange, StartsAtCharacter(0));

      expect(fooNameRange, EndsAtLine(0));
      expect(fooNameRange, EndsAtCharacter(4));

      expect(fooSymbolRange, StartsAtLine(0));
      expect(fooSymbolRange, StartsAtCharacter(0));

      expect(fooSymbolRange, EndsAtLine(2));
      expect(fooSymbolRange, EndsAtCharacter(1));

      var barNameRange = result.last.selectionRange;
      var barSymbolRange = result.last.range;

      expect(barNameRange, StartsAtLine(4));
      expect(barNameRange, StartsAtCharacter(0));

      expect(barNameRange, EndsAtLine(4));
      expect(barNameRange, EndsAtCharacter(4));

      expect(barSymbolRange, StartsAtLine(4));
      expect(barSymbolRange, StartsAtCharacter(0));

      expect(barSymbolRange, EndsAtLine(6));
      expect(barSymbolRange, EndsAtCharacter(1));
    });

    test('Sass indented selector ranges are correct', () {
      var document = fs.createDocument('''
.foo
  color: red

.bar
  color: blue

''', uri: 'index.sass');

      var result = ls.findDocumentSymbols(document);

      expect(result.first.selectionRange, StartsAtLine(0));
      expect(result.first.selectionRange, StartsAtCharacter(0));

      expect(result.first.selectionRange, EndsAtLine(0));
      expect(result.first.selectionRange, EndsAtCharacter(4));

      expect(result.first.range, StartsAtLine(0));
      expect(result.first.range, StartsAtCharacter(0));

      expect(result.first.range, EndsAtLine(1));
      expect(result.first.range, EndsAtCharacter(12));

      expect(result.last.selectionRange, StartsAtLine(3));
      expect(result.last.selectionRange, StartsAtCharacter(0));

      expect(result.last.selectionRange, EndsAtLine(3));
      expect(result.last.selectionRange, EndsAtCharacter(4));

      expect(result.last.range, StartsAtLine(3));
      expect(result.last.range, StartsAtCharacter(0));

      expect(result.last.range, EndsAtLine(4));
      expect(result.last.range, EndsAtCharacter(13));
    });

    test('placeholder selector ranges are correct', () {
      var document = fs.createDocument('''
%waitforit {
  color: red;
}

%waaaaaitforit {
  color: blue;
}
''');
      var result = ls.findDocumentSymbols(document);

      expect(result.first.selectionRange, StartsAtLine(0));
      expect(result.first.selectionRange, StartsAtCharacter(0));

      expect(result.first.selectionRange, EndsAtLine(0));
      expect(result.first.selectionRange, EndsAtCharacter(10));

      expect(result.first.range, StartsAtLine(0));
      expect(result.first.range, StartsAtCharacter(0));

      expect(result.first.range, EndsAtLine(2));
      expect(result.first.range, EndsAtCharacter(1));

      expect(result.last.selectionRange, StartsAtLine(4));
      expect(result.last.selectionRange, StartsAtCharacter(0));

      expect(result.last.selectionRange, EndsAtLine(4));
      expect(result.last.selectionRange, EndsAtCharacter(14));

      expect(result.last.range, StartsAtLine(4));
      expect(result.last.range, StartsAtCharacter(0));

      expect(result.last.range, EndsAtLine(6));
      expect(result.last.range, EndsAtCharacter(1));
    });
  });

  group('variables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('CSS variable ranges are correct', () {
      var document = fs.createDocument('''
.hello {
  --world: blue;
  color: var(--world);
}
''');
      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.children!.first.selectionRange;
      var symbolRange = result.first.children!.first.range;

      expect(nameRange, StartsAtLine(1));
      expect(nameRange, StartsAtCharacter(2));

      expect(nameRange, EndsAtLine(1));
      expect(nameRange, EndsAtCharacter(9));

      expect(symbolRange, StartsAtLine(1));
      expect(symbolRange, StartsAtCharacter(2));

      expect(symbolRange, EndsAtLine(1));
      expect(symbolRange, EndsAtCharacter(15)); // excluding ;
    });

    test('Sass variable ranges are correct', () {
      var document = fs.createDocument(r'''
$world: blue;
.hello {
  color: $world;
}
''');
      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange, StartsAtLine(0));
      expect(nameRange, StartsAtCharacter(0));

      expect(nameRange, EndsAtLine(0));
      expect(nameRange, EndsAtCharacter(6));

      expect(symbolRange, StartsAtLine(0));
      expect(symbolRange, StartsAtCharacter(0));

      expect(symbolRange, EndsAtLine(0));
      expect(symbolRange, EndsAtCharacter(12)); // excluding ;
    });
  });

  group('callable', () {
    setUp(() {
      ls.cache.clear();
    });

    test('function ranges are correct', () {
      var document = fs.createDocument(r'''
@function doStuff($a: 1, $b: 2) {
  $value: $a + $b;
  @return $value;
}

@function doOtherStuff($a: 1, $b: 2) {
  $value: $a + $b;
  @return $value;
}
''');

      var result = ls.findDocumentSymbols(document);

      expect(result.first.selectionRange, StartsAtLine(0));
      expect(result.first.selectionRange, StartsAtCharacter(10));

      expect(result.first.selectionRange, EndsAtLine(0));
      expect(result.first.selectionRange, EndsAtCharacter(17));

      expect(result.first.range, StartsAtLine(0));
      expect(result.first.range, StartsAtCharacter(0));

      expect(result.first.range, EndsAtLine(3));
      expect(result.first.range, EndsAtCharacter(1));

      expect(result.last.selectionRange, StartsAtLine(5));
      expect(result.last.selectionRange, StartsAtCharacter(10));

      expect(result.last.selectionRange, EndsAtLine(5));
      expect(result.last.selectionRange, EndsAtCharacter(22));

      expect(result.last.range, StartsAtLine(5));
      expect(result.last.range, StartsAtCharacter(0));

      expect(result.last.range, EndsAtLine(8));
      expect(result.last.range, EndsAtCharacter(1));
    });

    test('mixin ranges are correct', () {
      var document = fs.createDocument(r'''
@mixin mixin1 {
  $value: 1;
  line-height: $value;
}

@mixin mixin2 {
  $value: 1;
  line-height: $value;
}
''');

      var result = ls.findDocumentSymbols(document);

      expect(result.first.selectionRange, StartsAtLine(0));
      expect(result.first.selectionRange, StartsAtCharacter(7));

      expect(result.first.selectionRange, EndsAtLine(0));
      expect(result.first.selectionRange, EndsAtCharacter(13));

      expect(result.first.range, StartsAtLine(0));
      expect(result.first.range, StartsAtCharacter(0));

      expect(result.first.range, EndsAtLine(3));
      expect(result.first.range, EndsAtCharacter(1));

      expect(result.last.selectionRange, StartsAtLine(5));
      expect(result.last.selectionRange, StartsAtCharacter(7));

      expect(result.last.selectionRange, EndsAtLine(5));
      expect(result.last.selectionRange, EndsAtCharacter(13));

      expect(result.last.range, StartsAtLine(5));
      expect(result.last.range, StartsAtCharacter(0));

      expect(result.last.range, EndsAtLine(8));
      expect(result.last.range, EndsAtCharacter(1));
    });
  });

  group('at-rules', () {
    setUp(() {
      ls.cache.clear();
    });

    test('@media ranges are correct', () {
      var document = fs.createDocument(r'''
@media screen
  body
    font-size: 16px

@media print
  body
    font-size: 14pt
''', uri: 'index.sass');

      var result = ls.findDocumentSymbols(document);

      expect(result.first.selectionRange, StartsAtLine(0));
      expect(result.first.selectionRange, StartsAtCharacter(7));

      expect(result.first.selectionRange, EndsAtLine(0));
      expect(result.first.selectionRange, EndsAtCharacter(13));

      expect(result.first.range, StartsAtLine(0));
      expect(result.first.range, StartsAtCharacter(0));

      expect(result.first.range, EndsAtLine(2));
      expect(result.first.range, EndsAtCharacter(19));

      expect(result.last.selectionRange, StartsAtLine(4));
      expect(result.last.selectionRange, StartsAtCharacter(7));

      expect(result.last.selectionRange, EndsAtLine(4));
      expect(result.last.selectionRange, EndsAtCharacter(12));

      expect(result.last.range, StartsAtLine(4));
      expect(result.last.range, StartsAtCharacter(0));

      expect(result.last.range, EndsAtLine(6));
      expect(result.last.range, EndsAtCharacter(19));
    });

    test('@font-face ranges are correct', () {
      var document = fs.createDocument(r'''
@font-face {
  font-family: "Vulf Mono", monospace;
}

@font-face {
  font-family: "Vulf", serif;
}
''');
      var result = ls.findDocumentSymbols(document);

      expect(result.first.selectionRange, StartsAtLine(0));
      expect(result.first.selectionRange, StartsAtCharacter(1));

      expect(result.first.selectionRange, EndsAtLine(0));
      expect(result.first.selectionRange, EndsAtCharacter(10));

      expect(result.first.range, StartsAtLine(0));
      expect(result.first.range, StartsAtCharacter(0));

      expect(result.first.range, EndsAtLine(2));
      expect(result.first.range, EndsAtCharacter(1));

      expect(result.last.selectionRange, StartsAtLine(4));
      expect(result.last.selectionRange, StartsAtCharacter(1));

      expect(result.last.selectionRange, EndsAtLine(4));
      expect(result.last.selectionRange, EndsAtCharacter(10));

      expect(result.last.range, StartsAtLine(4));
      expect(result.last.range, StartsAtCharacter(0));

      expect(result.last.range, EndsAtLine(6));
      expect(result.last.range, EndsAtCharacter(1));
    });

    test('@keyframes', () {
      var document = fs.createDocument(r'''
@keyframes animation {

}

@keyframes spinner {

}
''');
      var result = ls.findDocumentSymbols(document);

      expect(result.first.selectionRange, StartsAtLine(0));
      expect(result.first.selectionRange, StartsAtCharacter(11));

      expect(result.first.selectionRange, EndsAtLine(0));
      expect(result.first.selectionRange, EndsAtCharacter(20));

      expect(result.first.range, StartsAtLine(0));
      expect(result.first.range, StartsAtCharacter(0));

      expect(result.first.range, EndsAtLine(2));
      expect(result.first.range, EndsAtCharacter(1));

      expect(result.last.selectionRange, StartsAtLine(4));
      expect(result.last.selectionRange, StartsAtCharacter(11));

      expect(result.last.selectionRange, EndsAtLine(4));
      expect(result.last.selectionRange, EndsAtCharacter(18));

      expect(result.last.range, StartsAtLine(4));
      expect(result.last.range, StartsAtCharacter(0));

      expect(result.last.range, EndsAtLine(6));
      expect(result.last.range, EndsAtCharacter(1));
    });
  });
}
