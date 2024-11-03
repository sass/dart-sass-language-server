import 'package:lsp_server/lsp_server.dart';

/// Get a reasonable default for client capabilities for tests.
ClientCapabilities getCapabilities() {
  return ClientCapabilities(
      textDocument: TextDocumentClientCapabilities(
          completion: CompletionClientCapabilities(
            completionItem: CompletionClientCapabilitiesCompletionItem(
              snippetSupport: true,
              documentationFormat: [MarkupKind.Markdown, MarkupKind.PlainText],
            ),
          ),
          hover: HoverClientCapabilities(
              contentFormat: [MarkupKind.Markdown, MarkupKind.PlainText])));
}
