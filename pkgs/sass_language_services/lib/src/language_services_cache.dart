import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';

import 'features/document_links/stylesheet_document_link.dart';

class CacheEntry {
  TextDocument document;
  sass.Stylesheet stylesheet;
  List<StylesheetDocumentLink>? links;

  CacheEntry({
    required this.document,
    required this.stylesheet,
  });
}

class LanguageServicesCache {
  final Map<String, CacheEntry> _cache = {};

  sass.Stylesheet getStylesheet(TextDocument document) {
    final key = document.uri.toString();
    var cached = _cache[key];

    if (cached != null && cached.document.version == document.version) {
      return cached.stylesheet;
    }

    late final sass.Stylesheet stylesheet;
    final languageId = document.languageId;
    switch (languageId) {
      case 'css':
        stylesheet = sass.Stylesheet.parseCss(document.getText());
        break;
      case 'scss':
        stylesheet = sass.Stylesheet.parseScss(document.getText());
        break;
      case 'sass':
        stylesheet = sass.Stylesheet.parseSass(document.getText());
        break;
      default:
        throw 'Unsupported language ID $languageId';
    }

    _cache[key] = CacheEntry(document: document, stylesheet: stylesheet);

    return stylesheet;
  }

  TextDocument? getDocument(Uri uri) {
    return _cache[uri.toString()]?.document;
  }

  List<StylesheetDocumentLink>? getDocumentLinks(TextDocument document) {
    return _cache[document.uri.toString()]?.links;
  }

  void setDocumentLinks(
      TextDocument document, List<StylesheetDocumentLink> links) {
    _cache[document.uri.toString()]?.links = links;
  }

  Iterable<TextDocument> getDocuments() {
    return _cache.values.map((e) => e.document);
  }

  bool containsKey(Uri uri) {
    return _cache.containsKey(uri.toString());
  }

  void remove(Uri uri) {
    _cache.remove(uri.toString());
  }
}
