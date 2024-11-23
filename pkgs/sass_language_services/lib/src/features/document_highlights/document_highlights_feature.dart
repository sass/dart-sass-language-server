import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/find_references/find_references_visitor.dart';
import 'package:sass_language_services/src/utils/sass_lsp_utils.dart';

import '../go_to_definition/scope_visitor.dart';
import '../go_to_definition/scoped_symbols.dart';
import '../language_feature.dart';
import '../node_at_offset_visitor.dart';

class DocumentHighlightsFeature extends LanguageFeature {
  DocumentHighlightsFeature({required super.ls});

  List<lsp.DocumentHighlight> findDocumentHighlights(
      TextDocument document, lsp.Position position) {
    var stylesheet = ls.parseStylesheet(document);
    // Find the node whose definition we're looking for.
    var offset = document.offsetAt(position);
    var visitor = NodeAtOffsetVisitor(offset);
    var node = stylesheet.accept(visitor);
    if (node == null || node is sass.Stylesheet) {
      return [];
    }

    var name = getNodeName(node);
    if (name == null) {
      return [];
    }
    var kind = getNodeReferenceKind(node);

    var symbols = ScopedSymbols(
      stylesheet,
      document.languageId == 'sass' ? Dialect.indented : Dialect.scss,
    );
    var symbol = symbols.findSymbolFromNode(node);

    var result = <lsp.DocumentHighlight>[];
    var references = FindReferencesVisitor(document, name);
    for (var reference in references.candidates) {
      if (symbol != null) {
        if (symbol.referenceKind == reference.kind &&
            symbol.name == reference.name &&
            isSameRange(symbol.range, reference.location.range)) {
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
