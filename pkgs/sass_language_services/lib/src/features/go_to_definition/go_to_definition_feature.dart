import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/go_to_definition/scoped_symbols.dart';
import 'package:sass_language_services/src/features/node_at_offset_visitor.dart';

import '../language_feature.dart';
import 'scope_visitor.dart';

class GoToDefinitionFeature extends LanguageFeature {
  GoToDefinitionFeature({required super.ls});

  /// Returns a Location with:
  ///
  ///   1. The URI of the document containing the definition.
  ///   2. The selectionRange (or "nameRange") of the definition.
  ///
  Future<lsp.Location?> goToDefinition(
      TextDocument document, lsp.Position position) async {
    var stylesheet = ls.parseStylesheet(document);

    // Find the node whose definition we're looking for.
    var offset = document.offsetAt(position);
    var visitor = NodeAtOffsetVisitor(offset);
    var node = stylesheet.accept(visitor);
    if (node == null) {
      return null;
    }

    // Get the node's ReferenceKind and name so we can compare it to other symbols.
    var kind = getNodeReferenceKind(node);
    if (kind == null) {
      return null;
    }
    var name = getNodeName(node);
    if (name == null) {
      return null;
    }

    // Look for the symbol in the current document.
    // It may be a scoped symbol.
    var symbols = ScopedSymbols(stylesheet,
        document.languageId == 'sass' ? Dialect.indented : Dialect.scss);
    var symbol = symbols.findSymbolFromNode(node);
    if (symbol != null) {
      // Found the definition in the same document.
      return lsp.Location(uri: document.uri, range: symbol.selectionRange);
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
      }
    }

    var definition = await findInWorkspace<lsp.Location>(
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
        // `@forward` may add a prefix to [name],
        // but we're comparing it to symbols without that prefix.
        var unprefixedName = kind == ReferenceKind.function ||
                kind == ReferenceKind.mixin ||
                kind == ReferenceKind.variable
            ? name.replaceFirst(prefix, '')
            : name;

        var stylesheet = ls.parseStylesheet(document);
        var symbols = ScopedSymbols(stylesheet,
            document.languageId == 'sass' ? Dialect.indented : Dialect.scss);
        var symbol = symbols.globalScope.getSymbol(
          name: unprefixedName,
          referenceKind: kind,
        );

        if (symbol != null) {
          return [
            lsp.Location(uri: document.uri, range: symbol.selectionRange)
          ];
        }

        return null;
      },
    );

    if (definition != null && definition.isNotEmpty) {
      return definition.first;
    }

    // Fall back to "@import-style" lookup on the whole workspace.
    for (var document in ls.cache.getDocuments()) {
      var symbols = ls.findDocumentSymbols(document);
      for (var symbol in symbols) {
        if (symbol.name == name && symbol.referenceKind == kind) {
          return lsp.Location(uri: document.uri, range: symbol.range);
        }
      }
    }

    return null;
  }
}
