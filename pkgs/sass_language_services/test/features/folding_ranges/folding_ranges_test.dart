import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

lsp.FoldingRange fr(int startLine, int endLine) {
  return lsp.FoldingRange(
    startLine: startLine,
    endLine: endLine,
  );
}

void main() {
  group('folding ranges', () {
    setUp(() {
      ls.cache.clear();
    });

    test('style rules', () {
      var document = fs.createDocument('''
.foo {
  color: red;

  .bar {
    color: blue;
  }
}
''');

      var result = ls.getFoldingRanges(document);
      expect(result, hasLength(2));
      expect(
        result,
        equals([
          fr(0, 6),
          fr(3, 5),
        ]),
      );
    });

    test('mixin rules', () {
      var document = fs.createDocument('''@mixin foo {
  color: red;

  .bar {
    color: blue;
  }
}
''');

      var result = ls.getFoldingRanges(document);
      expect(result, hasLength(2));
      expect(
        result,
        equals([
          fr(0, 6),
          fr(3, 5),
        ]),
      );
    });

    test('include rules', () {
      var document = fs.createDocument('''@include foo {
  --color-foo: red;
}
''');

      var result = ls.getFoldingRanges(document);
      expect(result, hasLength(1));
      expect(
        result,
        equals([
          fr(0, 2),
        ]),
      );
    });
  });
}
