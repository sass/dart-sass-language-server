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
      required ReferenceKind referenceKind,
      required lsp.Range symbolRange,
      lsp.Range? nameRange,
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
      referenceKind: referenceKind,
      range: range,
      children: [],
      selectionRange: selectionRange,
      docComment: docComment,
      detail: detail,
      tags: tags,
      deprecated: _isDeprecated(docComment),
    );

    // Look to see if this symbol contains other symbols.

    var keep = <StylesheetDocumentSymbol>[];

    for (var other in symbols) {
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
        referenceKind: ReferenceKind.fontFace,
        symbolRange: toRange(node.span),
        nameRange: toRange(node.name.span),
      );
    } else if (node.name.asPlain!.startsWith('keyframes')) {
      var keyframesName = node.span.context.split(' ').elementAtOrNull(1);
      if (keyframesName != null) {
        var keyframesNameRange = lsp.Range(
          start: lsp.Position(
            line: node.name.span.start.line,
            character: node.name.span.end.column + 1,
          ),
          end: lsp.Position(
            line: node.name.span.end.line,
            character: node.name.span.end.column + 1 + keyframesName.length,
          ),
        );

        _collect(
          name: keyframesName,
          referenceKind: ReferenceKind.keyframe,
          symbolRange: toRange(node.span),
          nameRange: keyframesNameRange,
        );
      }
    }
  }

  @override
  void visitDeclaration(node) {
    super.visitDeclaration(node);
    var isCustomProperty =
        node.name.isPlain && node.name.asPlain!.startsWith("--");
    if (isCustomProperty) {
      _collect(
        name: node.name.span.text,
        referenceKind: ReferenceKind.customProperty,
        symbolRange: toRange(node.span),
        nameRange: toRange(node.name.span),
      );
    }
  }

  @override
  void visitFunctionRule(node) {
    super.visitFunctionRule(node);

    _collect(
      name: node.name,
      detail: _detail(node),
      referenceKind: ReferenceKind.function,
      docComment: node.comment?.docComment,
      symbolRange: toRange(node.span),
      nameRange: toRange(node.nameSpan),
    );
  }

  @override
  void visitMediaRule(node) {
    super.visitMediaRule(node);
    if (!node.query.isPlain) {
      return;
    }

    // node.query.span includes whitespace, so the range doesn't match node.query.asPlain
    var nameRange = lsp.Range(
      start: lsp.Position(
        line: node.span.start.line + node.query.span.start.line,
        character: node.span.start.column + node.query.span.start.column,
      ),
      end: lsp.Position(
        line: node.span.start.line + node.query.span.end.line,
        character: node.span.start.column +
            node.query.span.start.column +
            node.query.asPlain!.length,
      ),
    );

    _collect(
      name: '@media ${node.query.asPlain}',
      referenceKind: ReferenceKind.media,
      symbolRange: toRange(node.span),
      nameRange: nameRange,
    );
  }

  @override
  void visitMixinRule(node) {
    super.visitMixinRule(node);

    _collect(
      name: node.name,
      detail: _detail(node),
      referenceKind: ReferenceKind.mixin,
      docComment: node.comment?.docComment,
      symbolRange: toRange(node.span),
      nameRange: toRange(node.nameSpan),
    );
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
        String? name;
        lsp.Range? nameRange;
        lsp.Range? symbolRange;

        for (var component in complexSelector.components) {
          var selector = component.selector;

          if (name == null) {
            name = selector.span.text;
          } else {
            name = '$name ${selector.span.text}';
          }

          if (nameRange == null) {
            // The selector span seems to be relative to node, not to the file.
            nameRange = lsp.Range(
              start: lsp.Position(
                line: node.span.start.line + selector.span.start.line,
                character: node.span.start.column + selector.span.start.column,
              ),
              end: lsp.Position(
                line: node.span.start.line + selector.span.end.line,
                character: node.span.start.column + selector.span.end.column,
              ),
            );

            // symbolRange: start position of selector's nameRange, end of stylerule (node.span.end).
            symbolRange = lsp.Range(
              start: lsp.Position(
                line: nameRange.start.line,
                character: nameRange.start.character,
              ),
              end: lsp.Position(
                line: node.span.end.line,
                character: node.span.end.column,
              ),
            );
          } else {
            // Move the end of the name range down to include this selector component
            nameRange = lsp.Range(
              start: nameRange.start,
              end: lsp.Position(
                line: node.span.start.line + selector.span.end.line,
                character: node.span.start.column + selector.span.end.column,
              ),
            );
          }
        }

        _collect(
          name: name!,
          referenceKind: ReferenceKind.selector,
          symbolRange: symbolRange!,
          nameRange: nameRange,
        );
      }
    } on sass.SassFormatException catch (_) {
      // Do nothing.
    }
  }

  @override
  void visitVariableDeclaration(node) {
    super.visitVariableDeclaration(node);
    _collect(
      name: node.nameSpan.text,
      referenceKind: ReferenceKind.variable,
      docComment: node.comment?.docComment,
      symbolRange: toRange(node.span),
      nameRange: lsp.Range(
        start: lsp.Position(
          line: node.nameSpan.start.line,
          // the span includes $
          character: node.nameSpan.start.column,
        ),
        end: lsp.Position(
          line: node.nameSpan.end.line,
          character: node.nameSpan.end.column,
        ),
      ),
    );
  }
}
