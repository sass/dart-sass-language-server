import 'package:lsp_server/lsp_server.dart' as lsp;

enum LinkType { use, forward, import }

class StylesheetDocumentLink extends lsp.DocumentLink {
  final LinkType type;

  final String? namespace;
  final String? prefix;
  final Set<String>? hiddenVariables;
  final Set<String>? shownVariables;
  final Set<String>? hiddenMixinsAndFunctions;
  final Set<String>? shownMixinsAndFunctions;

  StylesheetDocumentLink({
    super.data,
    required this.type,
    required super.range,
    super.target,
    super.tooltip,
    this.namespace,
    this.prefix,
    this.hiddenVariables,
    this.shownVariables,
    this.hiddenMixinsAndFunctions,
    this.shownMixinsAndFunctions,
  });
}
