import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/node_at_offset_visitor.dart';

import '../language_feature.dart';

class GoToDefinitionFeature extends LanguageFeature {
  GoToDefinitionFeature({required super.ls});

  /// Find the definition of whatever is at [position] in [document] if possible.
  ///
  /// At the end of this method we want to end up with two values:
  ///
  ///   1. The URI of the document containing the definition.
  ///   2. The selectionRange (or "nameRange") of the definition.
  ///
  /// To get that we compare the symbol at [position] in [document] with all
  /// symbols in all other documents.
  ///
  /// In order to support prefixes, show and hide we use links to traverse
  /// the workspace from [document]. If we find no match that way we fall
  /// back to "@import-style" and check all documents in the workspace for
  /// a match.
  Future<lsp.Location?> findDefinition(
      TextDocument document, lsp.Position position) async {
    var stylesheet = ls.parseStylesheet(document);


    var offset = document.offsetAt(position);
    var nodeAtOffset = stylesheet.accept(NodeAtOffsetVisitor(offset));

    var definition = findInWorkspace<lsp.Location>(
      lazy: true,
      initialDocument: document,
      callback: ({
        required TextDocument document,
        required String prefix,
        required List<String> hiddenMixinsAndFunctions,
        required List<String> hiddenVariables,
        required List<String> shownMixinsAndFunctions,
        required List<String> shownVariables,
      }) async {
        var symbols = ls.findDocumentSymbols(document);
        for (var symbol in symbols) {
          if (symbol.kind == lsp.SymbolKind.Class) {
            // Placeholder selectors are not prefixed the same way other symbols are.
            if (nodeAtOffset != null && nodeAtOffset.span)
          }
        }
      },
    );

    // If we can't essentially do what we do in workspace symbols

    // Remember to include upstream

    return null;
  }
}
