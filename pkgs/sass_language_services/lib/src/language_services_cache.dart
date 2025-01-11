import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/go_to_definition/scoped_symbols.dart';

class CacheEntry {
  TextDocument document;
  sass.Stylesheet stylesheet;
  List<StylesheetDocumentLink>? links;
  ScopedSymbols? symbols;

  CacheEntry({
    required this.document,
    required this.stylesheet,
  });
}

/// Cache to reduce the amount of parsing and I/O.
class LanguageServicesCache {
  final Map<String, CacheEntry> _cache = {};

  /// Get a [sass.Stylesheet] from the cache.
  ///
  /// The document is parsed on a cache miss
  /// (either a new document or a new version of the document).
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

  /// Mark a document as changed manually.
  ///
  /// The cached [sass.Stylesheed] is removed and the document is reparsed.
  ///
  /// We need this non-version checking method because of
  /// the rename feature. With that feature the client can
  /// send us "the first version" of a TextDocument after
  /// a rename, except we already have our own version 1
  /// from the initial scan using [FileSystemProvider].
  sass.Stylesheet onDocumentChanged(TextDocument document) {
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

    final key = document.uri.toString();
    _cache[key] = CacheEntry(document: document, stylesheet: stylesheet);

    return stylesheet;
  }

  /// Get a cached [TextDocument] with the given [uri].
  TextDocument? getDocument(Uri uri) {
    return _cache[uri.toString()]?.document;
  }

  /// Get the cached links for [TextDocument].
  ///
  /// We cache this to save on I/O.
  List<StylesheetDocumentLink>? getDocumentLinks(TextDocument document) {
    return _cache[document.uri.toString()]?.links;
  }

  /// Get the cached symbols for [TextDocument].
  ///
  /// We cache this since some workspace features read these symbols
  /// for all linked documents (recursively), which can get CPU intensive.
  ScopedSymbols? getDocumentSymbols(TextDocument document) {
    return _cache[document.uri.toString()]?.symbols;
  }

  /// Store the result from [LanguageServices.findDocumentLinks].
  void setDocumentLinks(
      TextDocument document, List<StylesheetDocumentLink> links) {
    _cache[document.uri.toString()]?.links = links;
  }

  /// Store the result from [ScopedSymbols].
  void setDocumentSymbols(TextDocument document, ScopedSymbols symbols) {
    _cache[document.uri.toString()]?.symbols = symbols;
  }

  /// Get all [TextDocument]s from the cache.
  Iterable<TextDocument> getDocuments() {
    return _cache.values.map((e) => e.document);
  }

  /// See if the cache contains the document at [uri].
  bool containsKey(Uri uri) {
    return _cache.containsKey(uri.toString());
  }

  /// Remove the document at [uri] from the cache.
  void remove(Uri uri) {
    _cache.remove(uri.toString());
  }

  /// Empty the cache.
  void clear() {
    _cache.clear();
  }
}
