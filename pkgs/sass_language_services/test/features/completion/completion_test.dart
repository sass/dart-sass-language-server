import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void hasEntry(lsp.CompletionList result, String label) {
  expect(
    result.items.any((i) => i.label == label),
    isTrue,
    reason: 'Expected to find an entry with the label $label',
  );
}

void hasNoEntry(lsp.CompletionList result, String label) {
  expect(
    result.items.every((i) => i.label != label),
    isTrue,
    reason: 'Did not expect to find an entry with the label $label',
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
      hasEntry(result, 'display');
      hasEntry(result, 'font-size');
    });

    test('in an empty style rule for indented', () async {
      var document = fs.createDocument(r'''
.a
    // Here to stop removing trailing whitespace
''', uri: 'indented.sass');
      var result = await ls.doComplete(document, at(line: 1, char: 2));

      expect(result.items, isNotEmpty);
      hasEntry(result, 'display');
      hasEntry(result, 'font-size');
    });

    test('in style rule with other declarations', () async {
      var document = fs.createDocument(r'''
.a
  display: block
   // Here to stop removing trailing whitespace
''', uri: 'indented.sass');
      var result = await ls.doComplete(document, at(line: 2, char: 2));

      expect(result.items, isNotEmpty);
      hasEntry(result, 'display');
      hasEntry(result, 'font-size');
    });

    test('not outside of a style rule', () async {
      var document = fs.createDocument(r'''

.a {  }
''');
      var result = await ls.doComplete(document, at(line: 0, char: 0));

      hasNoEntry(result, 'display');
      hasNoEntry(result, 'font-size');
    });
  });

  group('CSS declaration values', () {
    setUp(() {
      ls.cache.clear();
    });

    test('in an empty style rule', () async {
      var document = fs.createDocument(r'''
.a {
  display: ;
}
''');
      var result = await ls.doComplete(document, at(line: 1, char: 11));

      expect(result.items, isNotEmpty);

      hasEntry(result, 'block');

      // Should not suggest new declarations
      // or irrelevant values.
      hasNoEntry(result, 'display');
      hasNoEntry(result, 'bottom'); // vertical-align value
    });
  });
}
