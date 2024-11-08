import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void main() {
  group('selectors', () {
    setUp(() {
      ls.cache.clear();
    });

    test('should collect CSS class selectors', () {
      var document = fs.createDocument('''
.foo {
  color: red;
}

.bar {
  color: blue;
}
''');

      var result = ls.findDocumentSymbols(document);
      expect(result.symbols.length, equals(2));

      expect(result.selectors.first.name, equals(".foo"));
      expect(result.selectors.last.name, equals(".bar"));
    });

    test('should treat CSS selectors with multiple classes as one', () {
      var document = fs.createDocument('''
.foo.bar {
  color: red;
}

.fizz .buzz {
  color: blue;
}
''');

      var result = ls.findDocumentSymbols(document);
      expect(result.symbols.length, equals(2));

      expect(result.selectors.first.name, equals(".foo.bar"));
      expect(result.selectors.last.name, equals(".fizz .buzz"));
    });

    test('should treat lists of selectors as separate', () {
      var document = fs.createDocument('''
.foo.bar,
.fizz .buzz {
  color: red;
}
''');

      var result = ls.findDocumentSymbols(document);
      expect(result.symbols.length, equals(2));

      expect(result.selectors.first.name, equals(".foo.bar"));
      expect(result.selectors.last.name, equals(".fizz .buzz"));
    });

    test('should include extras', () {
      var document = fs.createDocument('''
.foo:has([data-testid="bar"]) {
  color: red;
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(
          result.selectors.first.name, equals('.foo:has([data-testid="bar"])'));
    });
  });

  group('variables', () {
    test('CSS variables', () {
      var document = fs.createDocument('''
.hello {
  --world: blue;
  color: var(--world);
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.cssVariables.first.name, equals('--world'));
    });

    test('public variables', () {
      var document = fs.createDocument(r'''
$world: blue;
.hello {
  color: $world;
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.variables.first.name, equals(r'$world'));
    });
  });
}
