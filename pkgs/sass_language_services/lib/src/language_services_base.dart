import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'configuration/configuration.dart';
import 'file_system_provider.dart';
import 'language_services_cache.dart';

class LanguageServices {
  late final LanguageServicesCache cache;
  final lsp.ClientCapabilities clientCapabilities;
  final FileSystemProvider fileSystemProvider;

  LanguageServices({
    required this.clientCapabilities,
    required this.fileSystemProvider,
  }) {
    cache = LanguageServicesCache();
  }

  void configure(LanguageServerConfiguration configuration) {}

  sass.Stylesheet parseStylesheet(lsp.TextDocumentItem document) {
    return cache.getStylesheet(document);
  }
}
