import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';

import '../document_symbols/scope.dart';
import '../language_feature.dart';

class FoldingRangesFeature extends LanguageFeature {
  FoldingRangesFeature({required super.ls});

  List<lsp.FoldingRange> getFoldingRanges(TextDocument document) {
    var symbols = ls.getScopedSymbols(document);

    var result = <lsp.FoldingRange>[];
    // Omit the global scope.
    for (var childScope in symbols.globalScope.children) {
      result.addAll(_toFoldingRanges(document, childScope));
    }
    return result;
  }

  List<lsp.FoldingRange> _toFoldingRanges(TextDocument document, Scope scope) {
    var result = <lsp.FoldingRange>[];
    result.add(_toFoldingRange(document, scope));
    if (scope.children.isEmpty) {
      return result;
    }
    for (var childScope in scope.children) {
      result.addAll(_toFoldingRanges(document, childScope));
    }
    return result;
  }

  lsp.FoldingRange _toFoldingRange(TextDocument document, Scope scope) {
    var startLine = document.positionAt(scope.offset).line;
    var endLine = document.positionAt(scope.offset + scope.length).line;
    return lsp.FoldingRange(startLine: startLine, endLine: endLine);
  }
}
