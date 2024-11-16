import 'package:sass_api/sass_api.dart' as sass;

import '../document_symbols/stylesheet_document_symbol.dart';
import 'scope.dart';
import 'scope_visitor.dart';

ReferenceKind? getNodeReferenceKind(sass.AstNode node) {
  if (node is sass.VariableDeclaration) {
    return ReferenceKind.variable;
  } else if (node is sass.VariableExpression) {
    return ReferenceKind.variable;
  } else if (node is sass.Declaration) {
    var name = node.name;
    var isCustomProperty = name.isPlain && name.asPlain!.startsWith("--");

    if (isCustomProperty) {
      return ReferenceKind.customProperty;
    }
  } else if (node is sass.AtRule) {
    var name = node.name;
    var isKeyframe = name.isPlain && name.asPlain!.startsWith('keyframes');
    if (isKeyframe) {
      return ReferenceKind.keyframe;
    }
  } else if (node is sass.ComplexSelectorComponent) {
    return ReferenceKind.selector;
  } else if (node is sass.SimpleSelector) {
    return ReferenceKind.selector;
  } else if (node is sass.PlaceholderSelector) {
    return ReferenceKind.placeholderSelector;
  } else if (node is sass.MixinRule) {
    return ReferenceKind.mixin;
  } else if (node is sass.FunctionExpression) {
    return ReferenceKind.function;
  } else if (node is sass.FunctionRule) {
    return ReferenceKind.function;
  }

  return null;
}

String? getNodeName(sass.AstNode node) {
  if (node is sass.VariableDeclaration) {
    return node.name;
  } else if (node is sass.VariableExpression) {
    return node.name;
  } else if (node is sass.Declaration) {
    var name = node.name;
    var isCustomProperty = name.isPlain && name.asPlain!.startsWith("--");
    if (isCustomProperty) {
      return node.name.span.text;
    }
  } else if (node is sass.AtRule) {
    var name = node.name;
    var isKeyframe = name.isPlain && name.asPlain!.startsWith('keyframes');
    if (isKeyframe) {
      var keyframesName = node.span.context.split(' ').elementAtOrNull(1);
      return keyframesName;
    }
  } else if (node is sass.ComplexSelectorComponent) {
    var rule = node as sass.ComplexSelectorComponent;
    return rule.span.text;
  } else if (node is sass.SimpleSelector) {
    var rule = node;
    return rule.span.text;
  } else if (node is sass.PlaceholderSelector) {
    var placeholder = node;
    return placeholder.name;
  } else if (node is sass.MixinRule) {
    var mixin = node;
    return mixin.name;
  } else if (node is sass.FunctionExpression) {
    var function = node;
    return function.name;
  } else if (node is sass.FunctionRule) {
    var function = node;
    return function.name;
  }

  return null;
}

/// Helper to query the results of [ScopeVisitor].
class ScopedSymbols {
  final globalScope = Scope(length: double.maxFinite.floor(), offset: 0);

  ScopedSymbols(sass.Stylesheet stylesheet, Dialect dialect) {
    stylesheet.accept(ScopeVisitor(globalScope, dialect));
  }

  StylesheetDocumentSymbol? findSymbolFromNode(sass.AstNode node) {
    if (node.runtimeType is sass.Interpolation) {
      return null;
    }

    var referenceKind = getNodeReferenceKind(node);
    if (referenceKind != null) {
      return _findSymbol(node, referenceKind);
    }

    return null;
  }

  StylesheetDocumentSymbol? _findSymbol(
      sass.AstNode node, ReferenceKind referenceKind) {
    var name = getNodeName(node);
    if (name == null) {
      return null;
    }

    var scope = globalScope.findScope(offset: node.span.start.offset);
    while (scope != null) {
      var symbol = scope.getSymbol(name: name, referenceKind: referenceKind);
      if (symbol != null) {
        return symbol;
      }
      scope = scope.parent;
    }
    return null;
  }

  List<StylesheetDocumentSymbol> findSymbolsAtOffset(
      int offset, ReferenceKind referenceKind) {
    var result = <StylesheetDocumentSymbol>[];
    var found = <String, bool>{};
    var scope = globalScope.findScope(offset: offset);
    while (scope != null) {
      var symbols = scope.getSymbols();

      for (var symbol in symbols) {
        if (symbol.referenceKind == referenceKind &&
            !found.containsKey(symbol.name)) {
          found[symbol.name] = true;
          result.add(symbol);
        }
      }

      scope = scope.parent;
    }
    return result;
  }
}
