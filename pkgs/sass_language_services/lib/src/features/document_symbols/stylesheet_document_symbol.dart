import 'package:lsp_server/lsp_server.dart';

class StylesheetDocumentSymbol extends SymbolInformation {
  final String? documentation;

  StylesheetDocumentSymbol({
    required super.name,
    required super.kind,
    required super.location,
    super.tags,
    super.deprecated,
    this.documentation,
  });
}
