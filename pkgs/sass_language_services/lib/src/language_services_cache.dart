import 'package:intl/intl.dart';
import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'features/links/stylesheet_document_link.dart';

class CacheEntry {
  lsp.TextDocumentItem document;
  sass.Stylesheet stylesheet;
  List<StylesheetDocumentLink>? links;

  CacheEntry({
    required this.document,
    required this.stylesheet,
  });
}

class LanguageServicesCache {
  final Map<String, CacheEntry> _cache = {};

  sass.Stylesheet getStylesheet(lsp.TextDocumentItem document) {
    final key = document.uri.toString();
    var cached = _cache[key];

    if (cached != null && cached.document.version == document.version) {
      return cached.stylesheet;
    }

    late final sass.Stylesheet stylesheet;
    final languageId = document.languageId;
    switch (languageId) {
      case 'css':
        stylesheet = sass.Stylesheet.parseCss(document.text);
        break;
      case 'scss':
        stylesheet = sass.Stylesheet.parseScss(document.text);
        break;
      case 'sass':
        stylesheet = sass.Stylesheet.parseSass(document.text);
        break;
      default:
        throw Intl.message('Unsupported language ID $languageId',
            name: 'errUnsupportedLanguage',
            args: [languageId],
            desc:
                "Error message that gets thrown if there is no parser available for the document's language");
    }

    _cache[key] = CacheEntry(document: document, stylesheet: stylesheet);

    return stylesheet;
  }

  lsp.TextDocumentItem? getDocument(String uri) {
    return _cache[uri]?.document;
  }

  List<StylesheetDocumentLink>? getDocumentLinks(
      lsp.TextDocumentItem document) {
    return _cache[document.uri.toString()]?.links;
  }

  void setDocumentLinks(
      lsp.TextDocumentItem document, List<StylesheetDocumentLink> links) {
    _cache[document.uri.toString()]?.links = links;
  }

  Iterable<lsp.TextDocumentItem> getDocuments() {
    return _cache.values.map((e) => e.document);
  }

  bool containsKey(String uri) {
    return _cache.containsKey(uri);
  }

  void remove(String uri) {
    _cache.remove(uri);
  }
}
