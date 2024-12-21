import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void hasProperty(lsp.CompletionList result, String property) {
  expect(
    result.items.any((i) => i.label == property),
    isTrue,
    reason: 'Expected to find an entry for the $property property',
  );
}

void main() {
  group('CSS declarations', () {
    setUp(() {
      ls.cache.clear();
    });

    test('in an empty style rule', () async {
      var document = fs.createDocument(r'''
.a {  }
''');
      var result = await ls.doComplete(document, at(line: 0, char: 5));

      expect(result.items, isNotEmpty);
      hasProperty(result, 'display');
      hasProperty(result, 'font-size');
    });

    test('in an empty style rule for indented', () async {
      var document = fs.createDocument(r'''
.a
    // Here to stop removing trailing whitespace
''', uri: 'indented.sass');
      var result = await ls.doComplete(document, at(line: 1, char: 2));

      expect(result.items, isNotEmpty);
      hasProperty(result, 'display');
      hasProperty(result, 'font-size');
    });
  });
}
