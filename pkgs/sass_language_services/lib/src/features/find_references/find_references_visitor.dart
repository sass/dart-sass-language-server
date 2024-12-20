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
  final bool _isBuiltin;

  FindReferencesVisitor(this._document, this._name,
      {bool includeDeclaration = false, bool isBuiltin = false})
      : _includeDeclaration = includeDeclaration,
        _isBuiltin = isBuiltin;

  @override
  void visitDeclaration(sass.Declaration node) {
    var isCustomPropertyDeclaration =
        node.name.isPlain && node.name.asPlain!.startsWith('--');

    if (isCustomPropertyDeclaration && _includeDeclaration) {
      var name = node.name.asPlain!;
      if (!name.contains(_name)) {
        return;
      }
      var location = lsp.Location(
        range: toRange(node.name.span),
        uri: _document.uri,
      );
      candidates.add(
        Reference(
          name: name,
          location: location,
          kind: ReferenceKind.customProperty,
        ),
      );
    }
    super.visitDeclaration(node);
  }

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

  @override
  void visitForwardRule(sass.ForwardRule node) {
    // TODO: would be nice to have span information for forward visibility from sass_api. Even nicer if we could tell at this point wheter something is a mixin or a function.

    if (node.hiddenMixinsAndFunctions case var hiddenMixinsAndFunctions?) {
      for (var name in hiddenMixinsAndFunctions) {
        if (!name.contains(_name)) {
          continue;
        }

        var selectionRange = forwardVisibilityRange(node, name);
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

        var selectionRange = forwardVisibilityRange(node, '\$$name');
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

        var selectionRange = forwardVisibilityRange(node, name);
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

        var selectionRange = forwardVisibilityRange(node, '\$$name');
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
    var isCustomProperty =
        node.name == 'var' && node.arguments.positional.isNotEmpty;
    if (isCustomProperty) {
      var expression = node.arguments.positional.first;
      if (expression is sass.StringExpression &&
          !expression.hasQuotes &&
          expression.text.isPlain) {
        var name = expression.text.asPlain!;
        var location = lsp.Location(
          range: toRange(expression.text.span),
          uri: _document.uri,
        );
        candidates.add(
          Reference(
            name: name,
            location: location,
            kind: ReferenceKind.customProperty,
          ),
        );
      }
    } else {
      var name = node.name;

      // We don't have any good way to avoid name
      // collisions with CSS functions, so only include
      // builtins when used from a namespace.
      var unsafeBuiltin = _isBuiltin && node.namespace == null;
      if (!name.contains(_name) || unsafeBuiltin) {
        super.visitFunctionExpression(node);
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
    }

    super.visitFunctionExpression(node);
  }

  @override
  void visitFunctionRule(sass.FunctionRule node) {
    if (!_includeDeclaration) {
      super.visitFunctionRule(node);
      return;
    }
    var name = node.name;
    if (!name.contains(_name)) {
      super.visitFunctionRule(node);
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
      super.visitIncludeRule(node);
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
      super.visitMixinRule(node);
      return;
    }
    var name = node.name;
    if (!name.contains(_name)) {
      super.visitMixinRule(node);
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
  void visitStringExpression(sass.StringExpression node) {}

  @override
  void visitStyleRule(sass.StyleRule node) {
    if (!_includeDeclaration) {
      super.visitStyleRule(node);
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
          var selectorSpan = component.selector.span;
          var name = selectorSpan.text;
          if (!name.contains(_name)) {
            continue;
          }

          var nameRange = selectorNameRange(
            node: node.span,
            selector: selectorSpan,
          );

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
      super.visitVariableDeclaration(node);
      return;
    }
    var name = node.name;
    if (!name.contains(_name)) {
      super.visitVariableDeclaration(node);
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
      super.visitVariableExpression(node);
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
