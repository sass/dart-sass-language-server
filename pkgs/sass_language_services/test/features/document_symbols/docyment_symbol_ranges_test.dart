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

''', uri: 'index.sass');

      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange, StartsAtLine(0));
      expect(nameRange, StartsAtCharacter(0));

      expect(nameRange, EndsAtLine(0));
      expect(nameRange, EndsAtCharacter(4));

      expect(symbolRange, StartsAtLine(0));
      expect(symbolRange, StartsAtCharacter(0));

      expect(symbolRange, EndsAtLine(1));
      expect(symbolRange, EndsAtCharacter(12));
    });

    test('placeholder selector ranges are correct', () {
      var document = fs.createDocument('''
%waitforit {
  color: red;
}
''');
      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange, StartsAtLine(0));
      expect(nameRange, StartsAtCharacter(0));

      expect(nameRange, EndsAtLine(0));
      expect(nameRange, EndsAtCharacter(10));

      expect(symbolRange, StartsAtLine(0));
      expect(symbolRange, StartsAtCharacter(0));

      expect(symbolRange, EndsAtLine(2));
      expect(symbolRange, EndsAtCharacter(1));
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
''');

      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange, StartsAtLine(0));
      expect(nameRange, StartsAtCharacter(10));

      expect(nameRange, EndsAtLine(0));
      expect(nameRange, EndsAtCharacter(17));

      expect(symbolRange, StartsAtLine(0));
      expect(symbolRange, StartsAtCharacter(0));

      expect(symbolRange, EndsAtLine(3));
      expect(symbolRange, EndsAtCharacter(1));
    });

    test('mixin ranges are correct', () {
      var document = fs.createDocument(r'''
@mixin mixin1 {
  $value: 1;
  line-height: $value;
}
''');

      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange, StartsAtLine(0));
      expect(nameRange, StartsAtCharacter(7));

      expect(nameRange, EndsAtLine(0));
      expect(nameRange, EndsAtCharacter(13));

      expect(symbolRange, StartsAtLine(0));
      expect(symbolRange, StartsAtCharacter(0));

      expect(symbolRange, EndsAtLine(3));
      expect(symbolRange, EndsAtCharacter(1));
    });
  });

  group('at-rules', () {
    setUp(() {
      ls.cache.clear();
    });

    test('@media ranges are correct', () {
      var document = fs.createDocument(r'''
@media screen, print
  body
    font-size: 14pt
''', uri: 'index.sass');

      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange, StartsAtLine(0));
      expect(nameRange, StartsAtCharacter(7));

      expect(nameRange, EndsAtLine(0));
      expect(nameRange, EndsAtCharacter(20));

      expect(symbolRange, StartsAtLine(0));
      expect(symbolRange, StartsAtCharacter(0));

      expect(symbolRange, EndsAtLine(2));
      expect(symbolRange, EndsAtCharacter(19));
    });

    test('@font-face ranges are correct', () {
      var document = fs.createDocument(r'''
@font-face {
  font-family: "Vulf Mono", monospace;
}
''');
      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange, StartsAtLine(0));
      expect(nameRange, StartsAtCharacter(1));

      expect(nameRange, EndsAtLine(0));
      expect(nameRange, EndsAtCharacter(10));

      expect(symbolRange, StartsAtLine(0));
      expect(symbolRange, StartsAtCharacter(0));

      expect(symbolRange, EndsAtLine(2));
      expect(symbolRange, EndsAtCharacter(1));
    });

    test('@keyframes', () {
      var document = fs.createDocument(r'''
@keyframes animation {

}
''');
      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange, StartsAtLine(0));
      expect(nameRange, StartsAtCharacter(11));

      expect(nameRange, EndsAtLine(0));
      expect(nameRange, EndsAtCharacter(20));

      expect(symbolRange, StartsAtLine(0));
      expect(symbolRange, StartsAtCharacter(0));

      expect(symbolRange, EndsAtLine(2));
      expect(symbolRange, EndsAtCharacter(1));
    });
  });
}
