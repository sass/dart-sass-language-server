import 'dart:math';
import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';

final defaultConfiguration = LanguageServerConfiguration(
    css: LanguageConfiguration.from({}),
    scss: LanguageConfiguration.from({}),
    sass: LanguageConfiguration.from({}),
    editor: EditorConfiguration.from({}),
    workspace: WorkspaceConfiguration.from({}));

abstract class LanguageFeature {
  late final lsp.ClientCapabilities clientCapabilities;
  late final FileSystemProvider fs;
  late final LanguageServices ls;
  var _configuration = defaultConfiguration;

  LanguageFeature(
      {required this.clientCapabilities, required this.fs, required this.ls});

  void configure(LanguageServerConfiguration configuration) {
    _configuration = configuration;
  }

  /// Helper to do some kind of lookup for the import tree of [initialDocument].
  ///
  /// The [callback] is called for each document in the import tree. Documents will only get visited once.
  Future<List<T>> findInWorkspace<T>(
      {required Future<List<T>> Function(lsp.TextDocumentItem document,
              String prefix, List<String> hide, List<String> show)
          callback,
      required lsp.TextDocumentItem initialDocument,
      bool lazy = false,
      int depth = 0}) async {
    return _findInWorkspace(
        callback: callback,
        initialDocument: initialDocument,
        currentDocument: initialDocument,
        depth: depth,
        lazy: lazy);
  }

  Future<List<T>> _findInWorkspace<T>(
      {required Future<List<T>> Function(lsp.TextDocumentItem document,
              String prefix, List<String> hide, List<String> show)
          callback,
      required lsp.TextDocumentItem initialDocument,
      required lsp.TextDocumentItem currentDocument,
      accumulatedPrefix = "",
      List<String> hide = const [],
      List<String> show = const [],
      Set<Uri> visited = const {},
      lazy = false,
      depth = 0}) async {
    if (visited.contains(currentDocument.uri)) {
      return Future.value([]);
    }

    throw "Not yet implemented";
  }

  DocumentContext getDocumentContext() {
    return DocumentContext(
        workspaceRoot: _configuration.workspace.workspaceRoot);
  }

  String getFileName(Uri uri) {
    var asString = uri.toString();
    var lastSlash = asString.lastIndexOf("/");
    return lastSlash == -1
        ? asString
        : asString.substring(max(0, lastSlash + 1));
  }

  LanguageConfiguration getLanguageConfiguration(
      lsp.TextDocumentItem document) {
    switch (document.languageId) {
      case 'css':
        return _configuration.css;
      case 'sass':
        return _configuration.sass;
      case 'scss':
        return _configuration.scss;
      default:
        throw 'Unsupported language ID ${document.languageId}';
    }
  }
}

class DocumentContext {
  Uri? workspaceRoot;

  DocumentContext({required this.workspaceRoot});

  String? resolveReference(String ref, String base) {
    throw "Not yet implemented";
    // TODO: implement vscode-uri's Utils.joinPath method. Skip encoding URI components.
    // if (ref.startsWith("/") && workspaceRoot != null) {
    //   return joinPath(workspaceRoot.toString(), ref)
    // }
    // TODO: figure out how to replicate the node resolve method in Dart
    // try {
    //   return resolve(base, ref);
    // } catch (e) {
    //   return null;
    // }
  }
}
