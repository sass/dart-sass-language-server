import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/find_references/find_references_visitor.dart';

import '../language_feature.dart';
import '../node_at_offset_visitor.dart';

class DocumentHighlightsFeature extends LanguageFeature {
  DocumentHighlightsFeature({required super.ls});

  List<lsp.DocumentHighlight> findDocumentHighlights(
      TextDocument document, lsp.Position position) {
    var stylesheet = ls.parseStylesheet(document);

    // Find the node whose definition we're looking for.
    var offset = document.offsetAt(position);
    var node = getNodeAtOffset(stylesheet, offset);
    if (node == null || node is sass.Stylesheet) {
      return [];
    }

    var name = getNodeName(node);
    if (name == null) {
      return [];
    }
    var kind = getNodeReferenceKind(node);

    var symbols = ls.getScopedSymbols(document);

    var symbol = symbols.findSymbolFromNode(node);

    var result = <lsp.DocumentHighlight>[];
    var visitor = FindReferencesVisitor(
      document,
      name,
      includeDeclaration: true,
    );

    stylesheet.accept(visitor);

    for (var reference in visitor.candidates) {
      if (symbol != null) {
        if (symbols.matchesSymbol(
          reference,
          document.offsetAt(reference.location.range.start),
          symbol,
        )) {
          result.add(
            lsp.DocumentHighlight(range: reference.location.range),
          );
        }
      } else if (kind != null &&
          reference.kind == kind &&
          reference.name == name) {
        result.add(
          lsp.DocumentHighlight(range: reference.location.range),
        );
      }
    }

    return result;
  }
}
