import 'package:lsp_server/lsp_server.dart';

class StylesheetDocumentSymbol extends DocumentSymbol {
  final String? documentation;

  StylesheetDocumentSymbol({
    required super.name,
    required super.kind,
    required super.range,
    required super.selectionRange,
    super.detail,
    super.children,
    super.tags,
    super.deprecated,
    this.documentation,
  });
}
