import 'package:lsp_server/lsp_server.dart' as lsp;

class StylesheetDocumentSymbol extends lsp.DocumentSymbol {
  final String? docComment;
  final ReferenceKind referenceKind;

  StylesheetDocumentSymbol({
    required super.name,
    required this.referenceKind,
    required super.range,
    required super.selectionRange,
    super.tags,
    super.deprecated,
    super.detail,
    super.children,
    this.docComment,
  }) : super(kind: _toKind(referenceKind));
}

/// Translate between [ReferenceKind] and the [lsp.SymbolKind] used by language clients.
lsp.SymbolKind _toKind(ReferenceKind kind) {
  switch (kind) {
    case ReferenceKind.atRule:
      return lsp.SymbolKind.Module;
    case ReferenceKind.mixin:
      return lsp.SymbolKind.Method;
    case ReferenceKind.function:
      return lsp.SymbolKind.Function;
    case ReferenceKind.variable:
      return lsp.SymbolKind.Variable;
    default:
      return lsp.SymbolKind.Class;
  }
}

enum ReferenceKind {
  atRule,
  customProperty,
  fontFace,
  forward,
  forwardVisibility,
  function,
  keyframe,
  mixin,
  module,
  media,
  selector,
  placeholderSelector,
  property,
  unknown,
  variable,
}
