import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/node_at_offset_visitor.dart';

import '../../utils/sass_lsp_utils.dart';
import '../language_feature.dart';
import 'definition.dart';

class GoToDefinitionFeature extends LanguageFeature {
  GoToDefinitionFeature({required super.ls});

  /// Returns a Location with:
  ///
  ///   1. The URI of the document containing the definition.
  ///   2. The selectionRange (or "nameRange") of the definition.
  ///
  Future<lsp.Location?> goToDefinition(
      TextDocument document, lsp.Position position) async {
    var definition = await internalGoToDefinition(document, position);
    return definition?.location;
  }

  Future<Definition?> internalGoToDefinition(
      TextDocument document, lsp.Position position) async {
    var stylesheet = ls.parseStylesheet(document);

    // Find the node whose definition we're looking for.
    var offset = document.offsetAt(position);
    var node = getNodeAtOffset(stylesheet, offset);
    if (node == null) {
      return null;
    }

    // The visibility configuration needs special handling.
    // We don't always know if something refers to a function or mixin, so
    // we check for both kinds. Only relevant for the workspace traversal though.
    String? name;
    var kinds = <ReferenceKind>[];
    if (node is sass.ForwardRule) {
      var result = _getForwardVisibilityCandidates(node, position);
      if (result != null) {
        (name, kinds) = result;
      }
    } else {
      // Get the node's ReferenceKind and name so we can compare it to other symbols.
      var kind = getNodeReferenceKind(node);
      if (kind == null) {
        return null;
      }
      kinds = [kind];

      name = getNodeName(node);
      if (name == null) {
        return null;
      }

      // Look for the symbol in the current document.
      // It may be a scoped symbol.
      var symbols = ls.getScopedSymbols(document);
      var symbol = symbols.findSymbolFromNode(node);
      if (symbol != null) {
        // Found the definition in the same document.
        return Definition(
          name,
          kind,
          lsp.Location(uri: document.uri, range: symbol.selectionRange),
        );
      }
    }

    if (kinds.isEmpty) {
      return null;
    }
    if (name == null) {
      return null;
    }

    // Start looking from the linked document In case of a namespace
    // so we don't accidentally match with a symbol of the same kind
    // and name, but in a different module.
    String? namespace;
    if (node is sass.VariableExpression) {
      namespace = node.namespace;
    } else if (node is sass.IncludeRule) {
      namespace = node.namespace;
    } else if (node is sass.FunctionExpression) {
      namespace = node.namespace;
    }

    var initialDocument = document;
    if (namespace != null) {
      var links = await ls.findDocumentLinks(document);
      try {
        var link = links.firstWhere((l) => l.namespace == namespace);
        if (link.target case var target?) {
          initialDocument = await getTextDocument(target);
        }
      } on StateError {
        return null;
      } on UnsupportedError {
        // The target URI scheme may be unsupported.
        return null;
      }
    }

    var result =
        await findInWorkspace<(StylesheetDocumentSymbol, lsp.Location)>(
      lazy: true,
      initialDocument: initialDocument,
      depth: initialDocument.uri != document.uri ? 1 : 0,
      callback: ({
        required TextDocument document,
        required String prefix,
        required List<String> hiddenMixinsAndFunctions,
        required List<String> hiddenVariables,
        required List<String> shownMixinsAndFunctions,
        required List<String> shownVariables,
      }) async {
        for (var kind in kinds) {
          // `@forward` may add a prefix to [name],
          // but in [document] the symbols are without that prefix.
          var unprefixedName = kind == ReferenceKind.function ||
                  kind == ReferenceKind.mixin ||
                  kind == ReferenceKind.variable
              ? name!.replaceFirst(prefix, '')
              : name!;

          var symbols = ls.getScopedSymbols(document);

          var symbol = symbols.globalScope.getSymbol(
            name: unprefixedName,
            referenceKind: kind,
          );

          if (symbol != null) {
            return [
              (
                symbol,
                lsp.Location(uri: document.uri, range: symbol.selectionRange)
              )
            ];
          }
        }
        return null;
      },
    );

    var definition = result.result;
    var visited = result.visited;

    if (definition != null && definition.isNotEmpty) {
      var symbol = definition.first.$1;
      var location = definition.first.$2;
      return Definition(
        symbol.name,
        symbol.referenceKind,
        location,
      );
    }

    // Fall back to "@import-style" lookup on the rest of the workspace.
    for (var document in ls.cache.getDocuments()) {
      if (visited.contains(document.uri.toString())) {
        continue;
      }

      var symbols = ls.getScopedSymbols(document);

      for (var kind in kinds) {
        var symbol = symbols.globalScope.getSymbol(
          name: name,
          referenceKind: kind,
        );
        if (symbol != null) {
          return Definition(
            name,
            kind,
            lsp.Location(uri: document.uri, range: symbol.selectionRange),
          );
        }
      }
    }

    return Definition(name, kinds.first, null);
  }

  (String, List<ReferenceKind>)? _getForwardVisibilityCandidates(
      sass.ForwardRule node, lsp.Position position) {
    if (node.hiddenMixinsAndFunctions case var hiddenMixinsAndFunctions?) {
      for (var name in hiddenMixinsAndFunctions) {
        var selectionRange = forwardVisibilityRange(node, name);
        if (isInRange(position: position, range: selectionRange)) {
          return (name, [ReferenceKind.function, ReferenceKind.mixin]);
        }
      }
    }

    if (node.hiddenVariables case var hiddenVariables?) {
      for (var name in hiddenVariables) {
        var selectionRange = forwardVisibilityRange(node, '\$$name');
        if (isInRange(position: position, range: selectionRange)) {
          return (name, [ReferenceKind.variable]);
        }
      }
    }

    if (node.shownMixinsAndFunctions case var shownMixinsAndFunctions?) {
      for (var name in shownMixinsAndFunctions) {
        var selectionRange = forwardVisibilityRange(node, name);
        if (isInRange(position: position, range: selectionRange)) {
          return (name, [ReferenceKind.function, ReferenceKind.mixin]);
        }
      }
    }

    if (node.shownVariables case var shownVariables?) {
      for (var name in shownVariables) {
        var selectionRange = forwardVisibilityRange(node, '\$$name');
        if (isInRange(position: position, range: selectionRange)) {
          return (name, [ReferenceKind.variable]);
        }
      }
    }
    return null;
  }
}
