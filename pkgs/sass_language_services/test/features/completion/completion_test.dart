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

    // TODO: The parser throws if the stylesheet is not valid which makes implementing completions a bit tricky.
    // Error: Expected expression.
    //    ╷
    //  2 │   display: ;
    //    │            ^
    //    ╵
    //    - 2:12  root stylesheet
    //  package:sass/src/utils.dart 428:3                                                     throwWithTrace
    //  package:sass/src/parse/parser.dart 732:7                                              Parser.wrapSpanFormatException
    //  package:sass/src/parse/stylesheet.dart 86:12                                          StylesheetParser.parse
    //  package:sass/src/ast/sass/statement/stylesheet.dart 134:38                            new Stylesheet.parseScss
    //  package:sass_language_services/src/language_services_cache.dart 35:38                 LanguageServicesCache.getStylesheet
    //  package:sass_language_services/src/language_services.dart 106:18                      LanguageServices.parseStylesheet
    //  package:sass_language_services/src/features/completion/completion_feature.dart 52:25  CompletionFeature.doComplete
    //  package:sass_language_services/src/language_services.dart 61:24                       LanguageServices.doComplete
    //  test/features/completion/completion_test.dart 94:29                                   main.<fn>.<fn>
    test('for display', () async {
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
