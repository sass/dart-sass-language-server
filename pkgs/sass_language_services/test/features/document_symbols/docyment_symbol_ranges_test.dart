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
''');

      var result = ls.findDocumentSymbols(document);
      var nameRange = result.first.selectionRange;
      var symbolRange = result.first.range;

      expect(nameRange.start, AtLine(0));
      expect(nameRange.start, AtCharacter(0));

      expect(nameRange.end, AtLine(0));
      expect(nameRange.end, AtCharacter(4));

      expect(symbolRange.start, AtLine(0));
      expect(symbolRange.start, AtCharacter(0));

      expect(symbolRange.end, AtLine(2));
      expect(symbolRange.end, AtCharacter(1));
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

      expect(symbolRange, EndsAtLine(2));
      expect(symbolRange, EndsAtCharacter(1));
    });
  });
}
