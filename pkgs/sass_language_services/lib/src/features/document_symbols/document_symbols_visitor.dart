import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/src/utils/sass_lsp_utils.dart';

import '../../lsp/text_document.dart';
import './stylesheet_document_symbols.dart';
import 'stylesheet_document_symbol.dart';

final quotes = RegExp('["\']');
final deprecated = RegExp(r'///\s*@deprecated');

class DocumentSymbolsVisitor with sass.RecursiveStatementVisitor {
  final symbols = StylesheetDocumentSymbols();

  final TextDocument _document;

  DocumentSymbolsVisitor(this._document);

  bool _isDeprecated(String? docComment) {
    if (docComment != null && deprecated.hasMatch(docComment)) {
      return true;
    }
    return false;
  }

  @override
  void visitAtRule(node) {
    super.visitAtRule(node);
    if (!node.name.isPlain) {
      return;
    }

    if (node.name.asPlain == 'font-face') {
      var symbol = StylesheetDocumentSymbol(
          name: '@${node.name.span.text.trim()}',
          kind: lsp.SymbolKind.Class,
          location:
              lsp.Location(range: toRange(node.name.span), uri: _document.uri));
      symbols.fontFaces.add(symbol);
    } else if (node.name.asPlain!.startsWith('keyframes')) {
      var keyframesName = node.span.context.split(' ').elementAtOrNull(1);
      if (keyframesName != null) {
        var keyframesNameRange = lsp.Range(
            start: lsp.Position(
                line: node.name.span.start.line,
                character: node.span.end.column + 1),
            end: lsp.Position(
                line: node.span.end.line,
                character: node.span.end.column + 1 + keyframesName.length));

        var symbol = StylesheetDocumentSymbol(
            name: keyframesName,
            kind: lsp.SymbolKind.Class,
            location:
                lsp.Location(range: keyframesNameRange, uri: _document.uri));
        symbols.keyframeIdentifiers.add(symbol);
      }
    }
  }

  @override
  void visitDeclaration(node) {
    super.visitDeclaration(node);
    if (node.name.isPlain && node.name.asPlain!.startsWith("--")) {
      var symbol = StylesheetDocumentSymbol(
          name: node.name.span.text.trim(),
          kind: lsp.SymbolKind.Variable,
          location:
              lsp.Location(range: toRange(node.name.span), uri: _document.uri));
      symbols.cssVariables.add(symbol);
    }
  }

  @override
  void visitFunctionRule(node) {
    super.visitFunctionRule(node);
    var symbol = StylesheetDocumentSymbol(
        name: node.name,
        kind: lsp.SymbolKind.Function,
        location:
            lsp.Location(range: toRange(node.nameSpan), uri: _document.uri),
        docComment: node.comment?.docComment,
        deprecated: _isDeprecated(node.comment?.docComment));
    symbols.functions.add(symbol);
  }

  @override
  void visitMediaRule(node) {
    super.visitMediaRule(node);
    if (!node.query.isPlain) {
      return;
    }
    var symbol = StylesheetDocumentSymbol(
        name: '@media ${node.query.asPlain}',
        kind: lsp.SymbolKind.Module,
        location: lsp.Location(range: toRange(node.span), uri: _document.uri));
    symbols.mediaQueries.add(symbol);
  }

  @override
  void visitMixinRule(node) {
    super.visitMixinRule(node);
    var symbol = StylesheetDocumentSymbol(
        name: node.name,
        kind: lsp.SymbolKind.Function,
        location:
            lsp.Location(range: toRange(node.nameSpan), uri: _document.uri),
        docComment: node.comment?.docComment,
        deprecated: _isDeprecated(node.comment?.docComment));
    symbols.mixins.add(symbol);
  }

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

  @override
  void visitVariableDeclaration(node) {
    super.visitVariableDeclaration(node);
    var symbol = StylesheetDocumentSymbol(
        // Include the $ since this field is user-facing
        name: '\$${node.name}',
        kind: lsp.SymbolKind.Variable,
        location:
            lsp.Location(range: toRange(node.nameSpan), uri: _document.uri),
        docComment: node.comment?.docComment,
        deprecated: _isDeprecated(node.comment?.docComment));
    symbols.variables.add(symbol);
  }
}
