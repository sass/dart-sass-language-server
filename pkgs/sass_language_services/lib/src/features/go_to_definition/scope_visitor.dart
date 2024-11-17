import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;

import '../../utils/sass_lsp_utils.dart';
import '../document_symbols/stylesheet_document_symbol.dart';
import 'scope.dart';

final deprecated = RegExp(r'///\s*@deprecated');
final openBracketOrNewline = RegExp(r'[\{\n]');

enum Dialect { scss, indented }

/// Builds scopes and a list of symbols in those scopes starting at [scope] (typically the global scope).
class ScopeVisitor with sass.RecursiveStatementVisitor {
  final Scope scope;
  final Dialect dialect;

  ScopeVisitor(
    this.scope,
    this.dialect,
  );

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
  void visitDeclaration(node) {
    var isCustomProperty =
        node.name.isPlain && node.name.asPlain!.startsWith("--");
    if (isCustomProperty) {
      // Add all custom properties to the global scope.

      var range = toRange(node.span);
      var selectionRange = toRange(node.name.span);

      var symbol = StylesheetDocumentSymbol(
        name: node.name.span.text,
        referenceKind: ReferenceKind.customProperty,
        range: range,
        children: [],
        selectionRange: selectionRange,
      );

      scope.addSymbol(symbol);
    }

    super.visitDeclaration(node);
  }

  @override
  void visitEachRule(sass.EachRule node) {
    var lengthSubtract = node.list.span.end.offset - node.span.start.offset;
    var scope = _addScope(
      offset: node.list.span.end.offset,
      length: node.span.length - lengthSubtract,
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
    var toEndIndex = node.to.span.end.offset - node.span.start.offset;
    var scopeIndex = node.span.text.indexOf(openBracketOrNewline, toEndIndex);
    var scope = _addScope(
      offset: node.span.start.offset + scopeIndex,
      length: node.span.length - scopeIndex,
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

    var argsEndIndex = node.arguments.span.end.offset - node.span.start.offset;
    var scopeIndex = node.span.text.indexOf(openBracketOrNewline, argsEndIndex);
    var scope = _addScope(
      offset: node.span.start.offset + scopeIndex,
      length: node.span.length - scopeIndex,
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
    // TODO: would be nice to have the spans for clauses from sass_api.
    Scope? previousClause;
    for (var clause in node.clauses) {
      var argsEndIndex =
          clause.expression.span.end.offset - node.span.start.offset;
      var scopeStartIndex =
          node.span.text.indexOf(openBracketOrNewline, argsEndIndex);

      var toMatch = dialect == Dialect.indented ? '\n' : '}';

      var lastChildIndex =
          node.span.text.indexOf(clause.children.last.span.text);
      var scopeEndIndex = node.span.text.indexOf(
          toMatch, lastChildIndex + clause.children.last.span.text.length);

      previousClause = _addScope(
        offset: node.span.start.offset + scopeStartIndex,
        length: scopeEndIndex - scopeStartIndex + 1,
      );
    }

    if (previousClause != null && node.lastClause != null) {
      var scopeIndex = node.span.text.indexOf(
          openBracketOrNewline,
          previousClause.offset -
              node.span.start.offset +
              previousClause.length +
              "@else".length);

      _addScope(
        offset: node.span.start.offset + scopeIndex,
        length: node.span.length - scopeIndex,
      );
    }

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

    var argsEndIndex = node.arguments.span.end.offset - node.span.start.offset;
    var scopeIndex = node.span.text.indexOf(openBracketOrNewline, argsEndIndex);
    var scope = _addScope(
      offset: node.span.start.offset + scopeIndex,
      length: node.span.length - scopeIndex,
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
          // we only want selectors that can be used in @extend
          if (complexSelector.components.isEmpty ||
              complexSelector.components.length > 1) {
            continue;
          }
          var component = complexSelector.components.first;

          var selector = component.selector;
          var name = selector.span.text;

          var nameRange = selectorNameRange(node, selector);

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
            kind: name.startsWith('%')
                ? ReferenceKind.placeholderSelector
                : ReferenceKind.selector,
            symbolRange: symbolRange,
            nameRange: nameRange,
            offset: node.span.start.offset,
            length: node.span.length,
          );
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
      name: node.name,
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
    var conditionEndIndex =
        node.condition.span.end.offset - node.span.start.offset;
    var scopeIndex =
        node.span.text.indexOf(openBracketOrNewline, conditionEndIndex);

    _addScope(
      offset: node.span.start.offset + scopeIndex,
      length: node.span.length - scopeIndex,
    );

    super.visitWhileRule(node);
  }
}
