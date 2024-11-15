import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;

import '../../utils/sass_lsp_utils.dart';
import '../document_symbols/stylesheet_document_symbol.dart';
import 'scope.dart';

final deprecated = RegExp(r'///\s*@deprecated');

/// Builds scopes and a list of symbols in those scopes starting at [scope] (typically the global scope).
class ScopeVisitor with sass.RecursiveStatementVisitor {
  final Scope scope;

  ScopeVisitor(this.scope);

  void _addSymbol({
    required String name,
    required ReferenceKind kind,
    required lsp.Range symbolRange,
    required int offset,
    required int length,
    lsp.Range? nameRange,
  }) {
    var symbolScope = scope.findScope(offset: offset, length: length);
    if (symbolScope != null) {
      var range = symbolRange;
      var selectionRange = nameRange;

      var symbol = StylesheetDocumentSymbol(
        name: name,
        referenceKind: kind,
        range: range,
        children: [],
        selectionRange: selectionRange ?? range,
      );

      symbolScope.addSymbol(symbol);
    }
  }

  Scope? _addScope({required int offset, required int length}) {
    var currentScope = scope.findScope(offset: offset, length: length);
    if (currentScope != null) {
      var isKnownScope =
          currentScope.offset == offset && currentScope.length == length;
      if (!isKnownScope) {
        var newScope = Scope(length: length, offset: offset);
        currentScope.addChild(newScope);
        return newScope;
      }
      return currentScope;
    }
    return null;
  }

  @override
  void visitAtRule(node) {
    if (node.name.isPlain) {
      if (node.name.asPlain == 'font-face') {
        _addSymbol(
          name: node.name.span.text,
          kind: ReferenceKind.atRule,
          symbolRange: toRange(node.span),
          nameRange: toRange(node.name.span),
          offset: node.span.start.offset,
          length: node.span.length,
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

          _addSymbol(
            name: keyframesName,
            kind: ReferenceKind.keyframe,
            symbolRange: toRange(node.span),
            nameRange: keyframesNameRange,
            offset: node.span.start.offset,
            length: node.span.length,
          );
        }
      }
    }

    super.visitAtRule(node);
  }

  @override
  void visitDeclaration(node) {
    var isCustomProperty =
        node.name.isPlain && node.name.asPlain!.startsWith("--");
    if (isCustomProperty) {
      _addSymbol(
        name: node.name.span.text,
        kind: ReferenceKind.variable,
        symbolRange: toRange(node.span),
        nameRange: toRange(node.name.span),
        offset: node.span.start.offset,
        length: node.span.length,
      );
    }

    super.visitDeclaration(node);
  }

  @override
  void visitEachRule(sass.EachRule node) {
    var scope = _addScope(
      offset: node.span.start.offset,
      length: node.span.length,
    );

    if (scope != null) {
      for (var variable in node.variables) {
        var variableIndex = node.span.text.indexOf(variable);

        var range = toRange(node.span);
        var selectionRange = lsp.Range(
          start: lsp.Position(
              line: node.span.start.line,
              character: node.span.start.column + variableIndex),
          end: lsp.Position(
            line: node.span.start.line,
            character: node.span.start.column + variable.length,
          ),
        );

        var symbol = StylesheetDocumentSymbol(
          name: variable,
          referenceKind: ReferenceKind.variable,
          range: range,
          children: [],
          selectionRange: selectionRange,
        );
        scope.addSymbol(symbol);
      }
    }

    super.visitEachRule(node);
  }

  @override
  void visitForRule(sass.ForRule node) {
    var scope = _addScope(
      offset: node.span.start.offset,
      length: node.span.length,
    );

    if (scope != null) {
      var variableIndex = node.span.text.indexOf(node.variable);

      var range = toRange(node.span);
      var selectionRange = lsp.Range(
        start: lsp.Position(
            line: node.span.start.line,
            character: node.span.start.column + variableIndex),
        end: lsp.Position(
          line: node.span.start.line,
          character: node.span.start.column + node.variable.length,
        ),
      );

      var symbol = StylesheetDocumentSymbol(
        name: node.variable,
        referenceKind: ReferenceKind.variable,
        range: range,
        children: [],
        selectionRange: selectionRange,
      );
      scope.addSymbol(symbol);
    }

    super.visitForRule(node);
  }

  @override
  void visitFunctionRule(node) {
    _addSymbol(
      name: node.name,
      kind: ReferenceKind.function,
      symbolRange: toRange(node.span),
      nameRange: toRange(node.nameSpan),
      offset: node.span.start.offset,
      length: node.span.length,
    );

    var scope = _addScope(
      offset: node.span.start.offset,
      length: node.span.length,
    );

    if (scope != null) {
      for (var arg in node.arguments.arguments) {
        var range = toRange(arg.span);
        var selectionRange = toRange(arg.nameSpan);
        var symbol = StylesheetDocumentSymbol(
          name: arg.name,
          referenceKind: ReferenceKind.variable,
          range: range,
          children: [],
          selectionRange: selectionRange,
        );
        scope.addSymbol(symbol);
      }
    }

    super.visitFunctionRule(node);
  }

  @override
  void visitIfRule(sass.IfRule node) {
    _addScope(
      offset: node.span.start.offset,
      length: node.span.length,
    );
    super.visitIfRule(node);
  }

  @override
  void visitMixinRule(node) {
    _addSymbol(
      name: node.name,
      kind: ReferenceKind.mixin,
      symbolRange: toRange(node.span),
      nameRange: toRange(node.nameSpan),
      offset: node.span.start.offset,
      length: node.span.length,
    );

    var scope = _addScope(
      offset: node.span.start.offset,
      length: node.span.length,
    );
    if (scope != null) {
      for (var arg in node.arguments.arguments) {
        var range = toRange(arg.span);
        var selectionRange = toRange(arg.nameSpan);
        var symbol = StylesheetDocumentSymbol(
          name: arg.name,
          referenceKind: ReferenceKind.variable,
          range: range,
          children: [],
          selectionRange: selectionRange,
        );
        scope.addSymbol(symbol);
      }
    }

    super.visitMixinRule(node);
  }

  @override
  void visitStyleRule(sass.StyleRule node) {
    if (node.selector.isPlain) {
      try {
        var selectorList = sass.SelectorList.parse(node.selector.asPlain!);
        for (var complexSelector in selectorList.components) {
          for (var component in complexSelector.components) {
            var selector = component.selector;
            var name = selector.span.text;

            // The selector span seems to be relative to node, not to the file.
            var nameRange = lsp.Range(
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
            var symbolRange = lsp.Range(
              start: lsp.Position(
                line: nameRange.start.line,
                character: nameRange.start.character,
              ),
              end: lsp.Position(
                line: node.span.end.line,
                character: node.span.end.column,
              ),
            );

            _addSymbol(
              name: name,
              kind: ReferenceKind.selector,
              symbolRange: symbolRange,
              nameRange: nameRange,
              offset: node.span.start.offset,
              length: node.span.length,
            );
          }
        }

        _addScope(
          offset: node.span.start.offset + node.selector.span.length,
          length: node.span.length - node.selector.span.length,
        );
      } on sass.SassFormatException catch (_) {
        // Do nothing.
      }
    }

    super.visitStyleRule(node);
  }

  @override
  void visitVariableDeclaration(node) {
    _addSymbol(
      name: node.nameSpan.text,
      kind: ReferenceKind.variable,
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
      offset: node.span.start.offset,
      length: node.span.length,
    );

    super.visitVariableDeclaration(node);
  }

  @override
  void visitWhileRule(sass.WhileRule node) {
    _addScope(
      offset: node.span.start.offset,
      length: node.span.length,
    );

    super.visitWhileRule(node);
  }
}
