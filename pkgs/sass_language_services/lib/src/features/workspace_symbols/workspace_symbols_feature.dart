import 'package:lsp_server/lsp_server.dart' as lsp;

import '../language_feature.dart';

class WorkspaceSymbolsFeature extends LanguageFeature {
  WorkspaceSymbolsFeature({required super.ls});

  List<lsp.WorkspaceSymbol> findWorkspaceSymbols(String? query) {
    var result = <lsp.WorkspaceSymbol>[];
    for (var document in ls.cache.getDocuments()) {
      // This is the exception to the rule that this enabled check
      // should happen at the server edge. It's only at this point
      // we know if the document should be included or not.
      var config = getLanguageConfiguration(document);
      if (config.workspaceSymbols.enabled) {
        var symbols = ls.findDocumentSymbols(document);
        for (var symbol in symbols) {
          if (query != null && !symbol.name.contains(query)) {
            continue;
          }

          result.add(lsp.WorkspaceSymbol(
              kind: symbol.kind,
              location: lsp.Either2.t1(
                  lsp.Location(range: symbol.range, uri: document.uri)),
              name: symbol.name,
              tags: symbol.tags));
        }
      }
    }
    return result;
  }
}
