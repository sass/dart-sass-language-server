import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'stylesheet_document_link.dart';

typedef UnresolvedLinkData = (StylesheetDocumentLink, bool);

final quotes = RegExp('["\']');

class DocumentLinkVisitor with sass.RecursiveStatementVisitor {
  List<UnresolvedLinkData> unresolvedLinks = [];

  @override
  void visitUseRule(sass.UseRule node) {
    super.visitUseRule(node);
    const isSassLink = true;
    unresolvedLinks.add((
      StylesheetDocumentLink(
        type: LinkType.use,
        target: node.url,
        range: lsp.Range(
          end: lsp.Position(
              line: node.urlSpan.end.line, character: node.urlSpan.end.column),
          start: lsp.Position(
              line: node.urlSpan.start.line,
              character: node.urlSpan.start.column),
        ),
        namespace: node.namespace,
      ),
      isSassLink
    ));
  }

  @override
  void visitForwardRule(sass.ForwardRule node) {
    super.visitForwardRule(node);
    const isSassLink = true;
    unresolvedLinks.add((
      StylesheetDocumentLink(
        type: LinkType.forward,
        target: node.url,
        range: lsp.Range(
          end: lsp.Position(
              line: node.urlSpan.end.line, character: node.urlSpan.end.column),
          start: lsp.Position(
              line: node.urlSpan.start.line,
              character: node.urlSpan.start.column),
        ),
        prefix: node.prefix,
        shownVariables: node.shownVariables,
        hiddenVariables: node.hiddenVariables,
        shownMixinsAndFunctions: node.shownMixinsAndFunctions,
        hiddenMixinsAndFunctions: node.hiddenMixinsAndFunctions,
      ),
      isSassLink
    ));
  }

  @override
  void visitImportRule(sass.ImportRule node) {
    super.visitImportRule(node);
    for (var import in node.imports) {
      if (import is sass.DynamicImport) {
        const isSassLink = true;
        unresolvedLinks.add((
          StylesheetDocumentLink(
            type: LinkType.import,
            target: import.url,
            range: lsp.Range(
              end: lsp.Position(
                  line: import.urlSpan.end.line,
                  character: import.urlSpan.end.column),
              start: lsp.Position(
                  line: import.urlSpan.start.line,
                  character: import.urlSpan.start.column),
            ),
          ),
          isSassLink
        ));
      } else {
        var staticImport = import as sass.StaticImport;

        Uri? target;
        if (import.url.isPlain) {
          // This text includes quotes (if they are present, optional in Indented)
          target = Uri.tryParse(import.span.text.replaceAll(quotes, ''));
        } else if (import.url.contents.isNotEmpty) {
          // drill down to the link target from f. ex. `@import url("foo.css");`
          var maybeUrlFunction = import.url.contents.first;
          if (maybeUrlFunction is sass.InterpolatedFunctionExpression) {
            if (maybeUrlFunction.arguments.positional.isNotEmpty) {
              var arg = maybeUrlFunction.arguments.positional.first;
              if (arg is sass.StringExpression && arg.text.isPlain) {
                target = Uri.tryParse(arg.text.asPlain!);
              }
            }
          }
        }

        const isSassLink = false;
        var urlSpan = staticImport.url.span;
        unresolvedLinks.add((
          StylesheetDocumentLink(
            type: LinkType.import,
            target: target,
            range: lsp.Range(
              end: lsp.Position(
                  line: urlSpan.end.line, character: urlSpan.end.column),
              start: lsp.Position(
                  line: urlSpan.start.line, character: urlSpan.start.column),
            ),
          ),
          isSassLink
        ));
      }
    }
  }
}
