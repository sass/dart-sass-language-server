import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;

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
  String? as;

  /// Either equal to [as] or derived from [target].
  String? namespace;

  List<String>? hide;

  List<String>? show;

  sass.AstNode node;

  StylesheetDocumentLink({
    super.data,
    required this.node,
    required super.range,
    super.target,
    super.tooltip,
  });
}
