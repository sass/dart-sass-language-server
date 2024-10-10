import 'package:lsp_server/lsp_server.dart' as lsp;

enum LinkType { use, forward, import }

class StylesheetDocumentLink extends lsp.DocumentLink {
  /// The alias, if any.
  ///
  /// | Link                         | Value       |
  /// | ---------------------------- | ----------- |
  /// | `@use "./colors"`            | `undefined` |
  /// | `@use "./colors" as c`       | `"c"`       |
  /// | `@use "./colors" as *`       | `"*"`       |
  /// | `@forward "./colors"`        | `undefined` |
  /// | `@forward "./colors" as c-*` | `"c"`       |
  String? alias;

  String? namespace;

  Set<String>? hiddenVariables;

  Set<String>? shownVariables;

  LinkType type;

  StylesheetDocumentLink({
    super.data,
    required this.type,
    required super.range,
    super.target,
    super.tooltip,
    this.alias,
    this.namespace,
    this.hiddenVariables,
    this.shownVariables,
  });
}
