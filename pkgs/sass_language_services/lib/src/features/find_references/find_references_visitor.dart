import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/utils/sass_lsp_utils.dart';

import 'reference.dart';

class FindReferencesVisitor
    with sass.RecursiveStatementVisitor, sass.RecursiveAstVisitor {
  final candidates = <Reference>[];

  final TextDocument _document;
  final String _name;
  final bool _includeDeclaration;

  FindReferencesVisitor(this._document, this._name,
      {bool includeDeclaration = false})
      : _includeDeclaration = includeDeclaration;

  @override
  void visitExtendRule(sass.ExtendRule node) {
    var isPlaceholderSelector =
        node.selector.isPlain && node.selector.asPlain!.startsWith('%');
    if (isPlaceholderSelector) {
      var name = node.selector.asPlain!;
      if (!name.contains(_name)) {
        return;
      }
      var location = lsp.Location(
        range: toRange(node.selector.span),
        uri: _document.uri,
      );
      candidates.add(
        Reference(
          name: name,
          location: location,
          kind: ReferenceKind.placeholderSelector,
        ),
      );
    }
    super.visitExtendRule(node);
  }

  lsp.Range _getForwardVisibilityRange(sass.ForwardRule node, String name) {
    var nameIndex = node.span.text.indexOf(
      name,
      node.span.start.offset - node.urlSpan.end.offset,
    );

    var selectionRange = lsp.Range(
      start: lsp.Position(
        line: node.span.start.line,
        character: node.span.start.column + nameIndex,
      ),
      end: lsp.Position(
        line: node.span.start.line,
        character: node.span.start.column + nameIndex + name.length,
      ),
    );
    return selectionRange;
  }

  @override
  void visitForwardRule(sass.ForwardRule node) {
    // TODO: would be nice to have span information for forward visibility from sass_api.

    if (node.hiddenMixinsAndFunctions case var hiddenMixinsAndFunctions?) {
      for (var name in hiddenMixinsAndFunctions) {
        if (!name.contains(_name)) {
          continue;
        }

        var selectionRange = _getForwardVisibilityRange(node, name);
        var location = lsp.Location(range: selectionRange, uri: _document.uri);

        // We can't tell if this is a mixin or a function, so add a candidate for both.
        candidates.add(
          Reference(
            name: name,
            location: location,
            kind: ReferenceKind.function,
          ),
        );
        candidates.add(
          Reference(
            name: name,
            location: location,
            kind: ReferenceKind.mixin,
          ),
        );
      }
    }

    if (node.hiddenVariables case var hiddenVariables?) {
      for (var name in hiddenVariables) {
        if (!name.contains(_name)) {
          continue;
        }

        var selectionRange = _getForwardVisibilityRange(node, name);
        var location = lsp.Location(range: selectionRange, uri: _document.uri);

        candidates.add(
          Reference(
            name: name,
            location: location,
            kind: ReferenceKind.variable,
          ),
        );
      }
    }

    if (node.shownMixinsAndFunctions case var shownMixinsAndFunctions?) {
      for (var name in shownMixinsAndFunctions) {
        if (!name.contains(_name)) {
          continue;
        }

        var selectionRange = _getForwardVisibilityRange(node, name);
        var location = lsp.Location(range: selectionRange, uri: _document.uri);

        // We can't tell if this is a mixin or a function, so add a candidate for both.
        candidates.add(
          Reference(
            name: name,
            location: location,
            kind: ReferenceKind.function,
          ),
        );
        candidates.add(
          Reference(
            name: name,
            location: location,
            kind: ReferenceKind.mixin,
          ),
        );
      }
    }

    if (node.shownVariables case var shownVariables?) {
      for (var name in shownVariables) {
        if (!name.contains(_name)) {
          continue;
        }

        var selectionRange = _getForwardVisibilityRange(node, name);
        var location = lsp.Location(range: selectionRange, uri: _document.uri);

        candidates.add(
          Reference(
            name: name,
            location: location,
            kind: ReferenceKind.variable,
          ),
        );
      }
    }

    super.visitForwardRule(node);
  }

  @override
  void visitFunctionExpression(sass.FunctionExpression node) {
    var name = node.name;
    if (!name.contains(_name)) {
      return;
    }
    var location = lsp.Location(
      range: toRange(node.nameSpan),
      uri: _document.uri,
    );
    candidates.add(
      Reference(
        name: name,
        location: location,
        kind: ReferenceKind.function,
      ),
    );
    super.visitFunctionExpression(node);
  }

  @override
  void visitFunctionRule(sass.FunctionRule node) {
    if (!_includeDeclaration) {
      return;
    }
    var name = node.name;
    if (!name.contains(_name)) {
      return;
    }
    var location = lsp.Location(
      range: toRange(node.nameSpan),
      uri: _document.uri,
    );
    candidates.add(
      Reference(
        name: name,
        location: location,
        kind: ReferenceKind.function,
      ),
    );
    super.visitFunctionRule(node);
  }

  @override
  void visitIncludeRule(sass.IncludeRule node) {
    var name = node.name;
    if (!name.contains(_name)) {
      return;
    }
    var location = lsp.Location(
      range: toRange(node.nameSpan),
      uri: _document.uri,
    );
    candidates.add(
      Reference(
        name: name,
        location: location,
        kind: ReferenceKind.mixin,
      ),
    );
    super.visitIncludeRule(node);
  }

  @override
  void visitMixinRule(sass.MixinRule node) {
    if (!_includeDeclaration) {
      return;
    }
    var name = node.name;
    if (!name.contains(_name)) {
      return;
    }
    var location = lsp.Location(
      range: toRange(node.nameSpan),
      uri: _document.uri,
    );
    candidates.add(
      Reference(
        name: name,
        location: location,
        kind: ReferenceKind.mixin,
      ),
    );
    super.visitMixinRule(node);
  }

  @override
  void visitStyleRule(sass.StyleRule node) {
    if (!_includeDeclaration) {
      return;
    }

    if (node.selector.isPlain) {
      try {
        var selectorList = sass.SelectorList.parse(node.selector.asPlain!);
        for (var complexSelector in selectorList.components) {
          var isPlaceholderSelector =
              node.selector.isPlain && node.selector.asPlain!.startsWith('%');
          if (!isPlaceholderSelector) {
            continue;
          }

          var component = complexSelector.components.first;
          var selector = component.selector;
          var name = selector.span.text;
          if (!name.contains(_name)) {
            continue;
          }

          var nameRange = selectorNameRange(node, selector);

          candidates.add(
            Reference(
              name: name,
              kind: ReferenceKind.placeholderSelector,
              location: lsp.Location(range: nameRange, uri: _document.uri),
            ),
          );
        }
      } on sass.SassFormatException catch (_) {
        // Do nothing.
      }
    }

    super.visitStyleRule(node);
  }

  @override
  void visitVariableDeclaration(sass.VariableDeclaration node) {
    if (!_includeDeclaration) {
      return;
    }
    var name = node.name;
    if (!name.contains(_name)) {
      return;
    }
    var location = lsp.Location(
      range: toRange(node.nameSpan),
      uri: _document.uri,
    );
    candidates.add(
      Reference(
        name: name,
        location: location,
        kind: ReferenceKind.variable,
      ),
    );
    super.visitVariableDeclaration(node);
  }

  @override
  void visitVariableExpression(sass.VariableExpression node) {
    var name = node.name;
    if (!name.contains(_name)) {
      return;
    }
    var location = lsp.Location(
      range: toRange(node.nameSpan),
      uri: _document.uri,
    );
    candidates.add(
      Reference(
        name: name,
        location: location,
        kind: ReferenceKind.variable,
      ),
    );
    super.visitVariableExpression(node);
  }
}
