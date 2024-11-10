import 'package:lsp_server/lsp_server.dart' as lsp;

import '../document_symbols/stylesheet_document_symbol.dart';

enum ReferenceKind {
  atRule,
  forward,
  forwardVisibility,
  function,
  keyframe,
  mixin,
  module,
  styleRule,
  placeholderSelector,
  property,
  unknown,
  variable,
}

/// Translate between [ReferenceKind] and the [lsp.SymbolKind] used by language clients.
lsp.SymbolKind toKind(ReferenceKind kind) {
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

class ScopedDocumentSymbol extends StylesheetDocumentSymbol {
  final ReferenceKind referenceKind;

  ScopedDocumentSymbol({
    required super.name,
    required super.range,
    required super.selectionRange,
    required this.referenceKind,
    super.children,
  }) : super(kind: toKind(referenceKind));
}
