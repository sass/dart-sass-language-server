import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

String? getContents(lsp.Hover? hover) {
  if (hover == null) return null;

  var result = hover.contents.map((v) => v, (v) => v);
  if (result is lsp.MarkupContent) {
    return result.value;
  } else {
    return result as String;
  }
}

void main() {
  group('CSS selectors', () {
    setUp(() {
      ls.cache.clear();
    });

    test('nested element selector', () async {
      var document = fs.createDocument(r'''
nav {
    ul {
        margin: 0;
        padding: 0;
        list-style: none;
    }

    li {
        display: inline-block;
    }

    a {
        display: block;
        padding: 6px 12px;
        text-decoration: none;
    }
}
''');
      var result = await ls.hover(document, at(line: 1, char: 5));

      expect(result, isNotNull);
      expect(getContents(result), contains('nav ul'));
      expect(getContents(result), contains('0, 0, 2'));
    });

    test('::has(.foo)', () {
      // TODO
    });
  });

  group('Parent selectors', () {
    setUp(() {
      ls.cache.clear();
    });

    test('simple parent selector', () async {
      var document = fs.createDocument(r'''
.button {
    &--primary {
        margin: 0;
        padding: 0;
    }
}
''');
      var result = await ls.hover(document, at(line: 1, char: 5));

      expect(result, isNotNull);
      expect(getContents(result), contains('.button--primary'));
      expect(getContents(result), contains('0, 1, 0'));
    });

    test('parent selector with extras', () async {
      var document = fs.createDocument(r'''
.button {
    &--primary::hover {
        margin: 0;
        padding: 0;
    }
}
''');
      var result = await ls.hover(document, at(line: 1, char: 17));

      expect(result, isNotNull);
      expect(getContents(result), contains('.button--primary::hover'));
      expect(getContents(result), contains('0, 1, 1'));
    });
  });
}
