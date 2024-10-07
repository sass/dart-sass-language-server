import 'package:lsp_server/lsp_server.dart' as lsp;
import '../language_feature.dart';
import 'stylesheet_document_link.dart';

class LinksFeature extends LanguageFeature {
  LinksFeature(
      {required super.clientCapabilities,
      required super.fs,
      required super.ls});

  Future<List<StylesheetDocumentLink>> findDocumentLinks(
      lsp.TextDocumentItem document) async {
    var cached = ls.cache.getDocumentLinks(document);
    if (cached != null) {
      return cached;
    }

    // TODO: implement links
    List<StylesheetDocumentLink> links = [];

    ls.cache.setDocumentLinks(document, links);
    return links;
  }
}
