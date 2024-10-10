import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import '../language_feature.dart';
import 'link_visitor.dart';
import 'stylesheet_document_link.dart';

final schemeRegex = RegExp(r'^\w+:\/\/');

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

    List<StylesheetDocumentLink> resolvedLinks = [];

    var stylesheet = ls.parseStylesheet(document);
    var context = getDocumentContext();

    var unresolvedLinks = _findUnresolvedLinks(document, stylesheet);
    for (var (link, isSassLink) in unresolvedLinks) {
      if (link.target == null) {
        continue;
      }

      var target = link.target.toString();
      if (target.startsWith("data:")) {
        continue;
      }

      if (target.startsWith("sass:")) {
        resolvedLinks.add(link);
        continue;
      }

      if (schemeRegex.hasMatch(target)) {
        resolvedLinks.add(link);
        continue;
      }

      var resolved =
          await _resolveReference(target, document.uri, context, isSassLink);
      if (resolved == null) {
        continue;
      }

      // lsp.DocumentLink.target is marked as final, so we make a new one
      resolvedLinks.add(StylesheetDocumentLink(
        target: resolved,
        range: link.range,
        data: link.data,
        tooltip: link.tooltip,
        alias: link.alias,
        namespace: link.namespace,
        hiddenVariables: link.hiddenVariables,
        shownVariables: link.shownVariables,
        type: link.type,
      ));
    }

    ls.cache.setDocumentLinks(document, resolvedLinks);
    return resolvedLinks;
  }

  List<UnresolvedLinkData> _findUnresolvedLinks(
      lsp.TextDocumentItem document, sass.Stylesheet stylesheet) {
    var visitor = LinkVisitor();
    stylesheet.accept(visitor);
    return visitor.unresolvedLinks;
  }

  Future<Uri?> _resolveReference(String target, Uri documentUri,
      DocumentContext context, bool isSassLink) async {
    // TODO
    return null;
  }
}
