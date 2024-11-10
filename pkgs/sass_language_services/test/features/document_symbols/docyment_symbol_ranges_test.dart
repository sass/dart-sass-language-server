import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_matchers.dart';
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
      expect(fooNameRange.start, AtLine(0));
      expect(fooNameRange.start, AtCharacter(0));

      expect(fooNameRange.end, AtLine(0));
      expect(fooNameRange.end, AtCharacter(4));

      expect(fooSymbolRange.start, AtLine(0));
      expect(fooSymbolRange.start, AtCharacter(0));

      expect(fooSymbolRange.end, AtLine(2));
      expect(fooSymbolRange.end, AtCharacter(1));

      var barNameRange = result.last.selectionRange;
      var barSymbolRange = result.last.range;

      expect(barNameRange.start, AtLine(4));
      expect(barNameRange.start, AtCharacter(0));

      expect(barNameRange.end, AtLine(4));
      expect(barNameRange.end, AtCharacter(4));

      expect(barSymbolRange.start, AtLine(4));
      expect(barSymbolRange.start, AtCharacter(0));

      expect(barSymbolRange.end, AtLine(6));
      expect(barSymbolRange.end, AtCharacter(1));
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
  });
}
