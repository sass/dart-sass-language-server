import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/src/utils/sass_lsp_utils.dart';

import '../../lsp/text_document.dart';
import './stylesheet_document_symbols.dart';
import 'stylesheet_document_symbol.dart';

final quotes = RegExp('["\']');

class DocumentSymbolsVisitor with sass.RecursiveStatementVisitor {
  final symbols = StylesheetDocumentSymbols();

  final TextDocument _document;

  DocumentSymbolsVisitor(this._document);

  @override
  void visitStyleRule(sass.StyleRule node) {
    super.visitStyleRule(node);

    if (!node.selector.isPlain) {
      // Keeping it simple for now.
      return;
    }

    try {
      var selectorList = sass.SelectorList.parse(node.selector.asPlain!);
      for (var complexSelector in selectorList.components) {
        var symbol = StylesheetDocumentSymbol(
            name: complexSelector.span.text.trim(),
            kind: lsp.SymbolKind.Class,
            location: lsp.Location(
                range: toRange(complexSelector.span), uri: _document.uri));

        symbols.selectors.add(symbol);
      }
    } on sass.SassFormatException catch (_) {
      // Do nothing.
    }
  }
}
