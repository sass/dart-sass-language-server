import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void expectRanges(TextDocument document, lsp.SelectionRange ranges,
    List<(int, String)> expected) {
  var pairs = <(int, String)>[];
  lsp.SelectionRange? current = ranges;
  while (current != null) {
    pairs.add((
      document.offsetAt(current.range.start),
      document.getText(range: current.range),
    ));
    current = current.parent;
  }
  expect(pairs, equals(expected));
}

void main() {
  group('selection ranges', () {
    setUp(() {
      ls.cache.clear();
    });

    test('style rules', () {
      var document = fs.createDocument('''.foo {
  color: red;

  .bar {
    color: blue;
  }
}
''');

      var result = ls.getSelectionRanges(document, [position(4, 5)]);
      expect(result, hasLength(1));
      expectRanges(document, result.first, [
        (0, ".foo {\n  color: red;\n\n  .bar {\n    color: blue;\n  }\n}\n"),
        (0, ".foo {\n  color: red;\n\n  .bar {\n    color: blue;\n  }\n}"),
        (24, ".bar {\n    color: blue;\n  }"),
        (35, "color: blue"),
        (35, "color")
      ]);
    });

    test('mixin rules', () {
      var document = fs.createDocument('''@mixin foo {
  color: red;

  .bar {
    color: blue;
  }
}
''');

      var result = ls.getSelectionRanges(document, [position(4, 5)]);
      expect(result, hasLength(1));
      expectRanges(document, result.first, [
        (
          0,
          "@mixin foo {\n  color: red;\n\n  .bar {\n    color: blue;\n  }\n}\n"
        ),
        (
          0,
          "@mixin foo {\n  color: red;\n\n  .bar {\n    color: blue;\n  }\n}"
        ),
        (30, ".bar {\n    color: blue;\n  }"),
        (41, "color: blue"),
        (41, "color")
      ]);
    });
  });
}
