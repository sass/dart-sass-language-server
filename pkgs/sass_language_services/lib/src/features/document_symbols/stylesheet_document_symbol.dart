import 'package:lsp_server/lsp_server.dart';

class StylesheetDocumentSymbol extends DocumentSymbol {
  final String? docComment;

  StylesheetDocumentSymbol({
    required super.name,
    required super.kind,
    required super.range,
    required super.selectionRange,
    super.tags,
    super.deprecated,
    super.detail,
    super.children,
    this.docComment,
  });
}
