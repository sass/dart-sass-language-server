import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void main() {
  group('Document symbols', () {
    setUp(() {
      ls.cache.clear();
    });

    test('should collect CSS class selectors', () async {
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

      expect(result.classes.first.name, equals(".foo"));
      expect(result.classes.last.name, equals(".bar"));
    });

    test('should collect individual CSS class selectors when combined',
        () async {
      var document = fs.createDocument('''
.foo.bar {
  color: red;
}

.fizz .buzz {
  color: blue;
}
''');

      var result = ls.findDocumentSymbols(document);
      expect(result.symbols.length, equals(4));

      expect(result.classes[0].name, equals(".foo"));
      expect(result.classes[1].name, equals(".bar"));
      expect(result.classes[2].name, equals(".fizz"));
      expect(result.classes[3].name, equals(".buzz"));
    });
  });
}
