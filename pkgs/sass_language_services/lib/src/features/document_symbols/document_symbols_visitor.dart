import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/src/utils/sass_lsp_utils.dart';

import 'stylesheet_document_symbol.dart';

final quotes = RegExp('["\']');
final deprecated = RegExp(r'///\s*@deprecated');

class DocumentSymbolsVisitor with sass.RecursiveStatementVisitor {
  final symbols = <StylesheetDocumentSymbol>[];

  DocumentSymbolsVisitor();

  /// Sort out the relationship between parent and child symbols.
  ///
  /// The visitor begins with the leaf nodes and travels recursively
  /// up before moving on to the next branch. We check to see
  /// if the symbol we're collecting now contains (based on its range)
  /// other symbols, and if so adds them as children.
  void _collect(
      {required String name,
      required lsp.SymbolKind kind,
      required lsp.Range symbolRange,
      lsp.Range? nameRange,
      lsp.Range? bodyRange, // TODO: delete if unused
      String? docComment,
      String? detail,
      List<lsp.SymbolTag>? tags}) {
    var range = symbolRange;
    var selectionRange = nameRange;
    if (selectionRange == null || !_containsRange(range, symbolRange)) {
      selectionRange = lsp.Range(start: range.start, end: range.end);
    }

    var symbol = StylesheetDocumentSymbol(
        name: name,
        kind: kind,
        range: range,
        children: [],
        selectionRange: selectionRange,
        docComment: docComment,
        detail: detail,
        tags: tags,
        deprecated: _isDeprecated(docComment));

    // Look to see if this symbol contains other symbols.

    var keep = <StylesheetDocumentSymbol>[];

    for (var other in symbols) {
      // This probably scales terribly with document size.
      // A tree structure that uses ranges for lookup would probably be the ticket here.
      // We can maybe get away with it if we cache the result.
      if (_containsRange(symbol.range, other.range)) {
        symbol.children!.add(other);
      } else {
        keep.add(other);
      }
    }

    keep.add(symbol);
    symbols.replaceRange(0, symbols.length, keep);
  }

  bool _containsRange(lsp.Range a, lsp.Range b) {
    if (b.start.line < a.start.line || b.end.line < a.start.line) {
      return false;
    }

    if (b.start.line > b.end.line || b.end.line > a.end.line) {
      return false;
    }

    if (b.start.line == a.start.line && b.start.character < a.start.character) {
      return false;
    }

    if (b.end.line == a.end.line && b.end.character > a.end.character) {
      return false;
    }

    return true;
  }

  bool _isDeprecated(String? docComment) {
    if (docComment != null && deprecated.hasMatch(docComment)) {
      return true;
    }
    return false;
  }

  lsp.Range? _bodyRange(sass.ParentStatement<List<sass.Statement>?> node) {
    if (node.children case var children?) {
      if (children.isEmpty) {
        return null;
      }

      return lsp.Range(
          start: lsp.Position(
              line: children.first.span.start.line,
              character: children.first.span.start.column),
          end: lsp.Position(
              line: children.last.span.start.line,
              character: children.last.span.start.column));
    }

    return null;
  }

  String? _detail(sass.CallableDeclaration node) {
    var arguments = node.arguments.arguments
        .map<String>((arg) => arg.defaultValue != null
            ? '${arg.name}: ${arg.defaultValue!.span.text}'
            : arg.name)
        .join(', ');
    return '($arguments)';
  }

  @override
  void visitAtRule(node) {
    super.visitAtRule(node);
    if (!node.name.isPlain) {
      return;
    }

    if (node.name.asPlain == 'font-face') {
      _collect(
          name: node.name.span.text,
          kind: lsp.SymbolKind.Class,
          symbolRange: toRange(node.span),
          nameRange: toRange(node.name.span),
          bodyRange: _bodyRange(node));
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

        _collect(
            name: keyframesName,
            kind: lsp.SymbolKind.Class,
            symbolRange: toRange(node.span),
            nameRange: keyframesNameRange,
            bodyRange: _bodyRange(node));
      }
    }
  }

  @override
  void visitDeclaration(node) {
    super.visitDeclaration(node);
    if (node.name.isPlain && node.name.asPlain!.startsWith("--")) {
      _collect(
          name: node.name.span.text,
          kind: lsp.SymbolKind.Variable,
          symbolRange: toRange(node.span),
          nameRange: toRange(node.name.span),
          bodyRange: _bodyRange(node));
    }
  }

  @override
  void visitFunctionRule(node) {
    super.visitFunctionRule(node);

    _collect(
        name: node.name,
        detail: _detail(node),
        kind: lsp.SymbolKind.Function,
        docComment: node.comment?.docComment,
        symbolRange: toRange(node.span),
        nameRange: toRange(node.nameSpan),
        bodyRange: _bodyRange(node));
  }

  @override
  void visitMediaRule(node) {
    super.visitMediaRule(node);
    if (!node.query.isPlain) {
      return;
    }

    _collect(
        name: '@media ${node.query.asPlain}',
        kind: lsp.SymbolKind.Module,
        symbolRange: toRange(node.span),
        nameRange: toRange(node.query.span),
        bodyRange: _bodyRange(node));
  }

  @override
  void visitMixinRule(node) {
    super.visitMixinRule(node);

    _collect(
        name: node.name,
        detail: _detail(node),
        kind: lsp.SymbolKind.Method,
        docComment: node.comment?.docComment,
        symbolRange: toRange(node.span),
        nameRange: toRange(node.nameSpan),
        bodyRange: _bodyRange(node));
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
        var nameRange = toRange(complexSelector.span);
        var nameWithoutTrailingSpace = complexSelector.span.text.trimRight();
        var diff =
            complexSelector.span.text.length - nameWithoutTrailingSpace.length;
        if (diff != 0) {
          nameRange = lsp.Range(
              start: lsp.Position(
                  line: node.span.start.line + nameRange.start.line,
                  character:
                      node.span.start.column + nameRange.start.character),
              end: lsp.Position(
                  line: node.span.start.line + nameRange.end.line,
                  character:
                      node.span.start.column + nameRange.end.character - diff));
        }

        // symbolRange: start position of selector's nameRange, end of stylerule (node.span.end).
        var symbolRange = lsp.Range(
            start: lsp.Position(
                line: nameRange.start.line,
                character: nameRange.start.character),
            end: lsp.Position(
                line: node.span.end.line, character: node.span.end.column));

        _collect(
            name: nameWithoutTrailingSpace,
            kind: lsp.SymbolKind.Class,
            symbolRange: symbolRange,
            nameRange: nameRange,
            bodyRange: _bodyRange(node));
      }
    } on sass.SassFormatException catch (_) {
      // Do nothing.
    }
  }

  @override
  void visitVariableDeclaration(node) {
    super.visitVariableDeclaration(node);
    _collect(
        // Include the $ since this field is user-facing
        name: '\$${node.name}',
        kind: lsp.SymbolKind.Variable,
        docComment: node.comment?.docComment,
        symbolRange: toRange(node.span),
        nameRange: lsp.Range(
            start: lsp.Position(
                line: node.nameSpan.start.line,
                // Include the $ in the range
                character: node.nameSpan.start.column - 1),
            end: lsp.Position(
                line: node.nameSpan.end.line,
                character: node.nameSpan.end.column)));
  }
}
