import 'package:lsp_server/lsp_server.dart';
import 'package:sass_language_server/src/lsp/text_document.dart';

class TextDocumentChangeEvent {
  final TextDocument document;

  TextDocumentChangeEvent(this.document);
}

class TextDocumentWillSaveEvent {
  final TextDocument document;
  final TextDocumentSaveReason reason;

  TextDocumentWillSaveEvent(this.document, this.reason);
}

/// Helper class handling the low-level methods to sync document
/// contents from the client. Mimics vscode-languageserver-node's
/// [TextDocuments](https://github.com/microsoft/vscode-languageserver-node/blob/main/server/src/common/textDocuments.ts)
class TextDocuments {
  final Map<Uri, TextDocument> _syncedDocuments = {};

  late final Future<void> Function(TextDocumentChangeEvent)? _onDidOpen;
  late final Future<void> Function(TextDocumentChangeEvent)?
      _onDidChangeContent;
  late final Future<void> Function(TextDocumentChangeEvent)? _onDidClose;
  late final Future<void> Function(TextDocumentChangeEvent)? _onWillSave;
  late final Future<List<TextEdit>> Function(TextDocumentWillSaveEvent)?
      _onWillSaveWaitUntil;
  late final Future<void> Function(TextDocumentChangeEvent)? _onDidSave;

  TextDocuments({
    Future<void> Function(TextDocumentChangeEvent)? onDidOpen,
    Future<void> Function(TextDocumentChangeEvent)? onDidChangeContent,
    Future<void> Function(TextDocumentChangeEvent)? onDidClose,
    Future<void> Function(TextDocumentChangeEvent)? onWillSave,
    Future<List<TextEdit>> Function(TextDocumentWillSaveEvent)?
        onWillSaveWaitUntil,
    Future<void> Function(TextDocumentChangeEvent)? onDidSave,
  }) {
    _onDidOpen = onDidOpen;
    _onDidChangeContent = onDidChangeContent;
    _onDidClose = onDidClose;
    _onWillSave = onWillSave;
    _onWillSaveWaitUntil = onWillSaveWaitUntil;
    _onDidSave = onDidSave;
  }

  TextDocument? get(Uri uri) {
    return _syncedDocuments[uri];
  }

  Iterable<TextDocument> all() {
    return _syncedDocuments.values;
  }

  Iterable<Uri> keys() {
    return _syncedDocuments.keys;
  }

  void listen(Connection connection) {
    connection.onDidOpenTextDocument((event) async {
      var td = event.textDocument;
      var document = TextDocument(td.uri, td.languageId, td.version, td.text);
      _syncedDocuments[document.uri] = document;

      if (_onDidOpen != null) {
        _onDidOpen(TextDocumentChangeEvent(document));
      }
      if (_onDidChangeContent != null) {
        _onDidChangeContent(TextDocumentChangeEvent(document));
      }
    });

    connection.onDidChangeTextDocument((event) async {
      var td = event.textDocument;
      var changes = event.contentChanges;
      if (changes.isEmpty) return;

      var version = td.version;
      var syncedDocument = get(td.uri);
      if (syncedDocument == null) return;

      syncedDocument.update(changes, version);

      if (_onDidChangeContent != null) {
        _onDidChangeContent(TextDocumentChangeEvent(syncedDocument));
      }
    });
  }
}
