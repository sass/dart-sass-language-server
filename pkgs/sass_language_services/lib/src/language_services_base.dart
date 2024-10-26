import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';

import 'configuration/configuration.dart';
import 'features/links/links_feature.dart';
import 'features/links/stylesheet_document_link.dart';
import 'file_system_provider.dart';
import 'language_services_cache.dart';

class LanguageServices {
  late final LanguageServicesCache cache;
  final lsp.ClientCapabilities clientCapabilities;
  final FileSystemProvider fs;

  LanguageServerConfiguration configuration =
      LanguageServerConfiguration.from(null);

  late final LinksFeature _links;

  LanguageServices({
    required this.clientCapabilities,
    required this.fs,
  }) {
    cache = LanguageServicesCache();
    _links = LinksFeature(ls: this);
  }

  void configure(LanguageServerConfiguration configuration) {
    configuration = configuration;
  }

  Future<List<StylesheetDocumentLink>> findDocumentLinks(
      TextDocument document) {
    return _links.findDocumentLinks(document);
  }

  sass.Stylesheet parseStylesheet(TextDocument document) {
    return cache.getStylesheet(document);
  }
}
