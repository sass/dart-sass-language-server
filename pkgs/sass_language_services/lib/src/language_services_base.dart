import 'package:intl/intl.dart';
import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;

import 'configuration/configuration.dart';
import 'features/links/links_feature.dart';
import 'features/links/stylesheet_document_link.dart';
import 'file_system_provider.dart';
import 'language_services_cache.dart';

class LanguageServices {
  late final LanguageServicesCache cache;
  final lsp.ClientCapabilities clientCapabilities;
  final FileSystemProvider fs;

  late final LinksFeature _links;

  LanguageServices({
    required this.clientCapabilities,
    required this.fs,
  }) {
    cache = LanguageServicesCache();
    _links = LinksFeature(ls: this);
  }

  void configure(LanguageServerConfiguration configuration) {
    Intl.defaultLocale = configuration.editor.locale;
  }

  Future<List<StylesheetDocumentLink>> findDocumentLinks(
      lsp.TextDocumentItem document) {
    return _links.findDocumentLinks(document);
  }

  sass.Stylesheet parseStylesheet(lsp.TextDocumentItem document) {
    return cache.getStylesheet(document);
  }
}
