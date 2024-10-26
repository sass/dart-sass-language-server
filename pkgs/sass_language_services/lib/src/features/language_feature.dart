import 'dart:math';

import '../../sass_language_services.dart';
import '../uri_utils.dart';

final defaultConfiguration = LanguageServerConfiguration.from(null);

abstract class LanguageFeature {
  late final LanguageServices ls;

  LanguageFeature({required this.ls});

  /// Helper to do some kind of lookup for the import tree of [initialDocument].
  ///
  /// The [callback] is called for each document in the import tree. Documents will only get visited once.
  Future<List<T>> findInWorkspace<T>(
      {required Future<List<T>> Function(TextDocument document, String prefix,
              List<String> hide, List<String> show)
          callback,
      required TextDocument initialDocument,
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
      {required Future<List<T>> Function(TextDocument document, String prefix,
              List<String> hide, List<String> show)
          callback,
      required TextDocument initialDocument,
      required TextDocument currentDocument,
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
        workspaceRoot: ls.configuration.workspace.workspaceRoot);
  }

  String getFileName(Uri uri) {
    var asString = uri.toString();
    var lastSlash = asString.lastIndexOf("/");
    return lastSlash == -1
        ? asString
        : asString.substring(max(0, lastSlash + 1));
  }

  LanguageConfiguration getLanguageConfiguration(TextDocument document) {
    final languageId = document.languageId;
    switch (languageId) {
      case 'css':
        return ls.configuration.css;
      case 'sass':
        return ls.configuration.sass;
      case 'scss':
        return ls.configuration.scss;
      default:
        throw 'Unsupported language ID $languageId';
    }
  }
}

class DocumentContext {
  Uri? workspaceRoot;

  DocumentContext({required this.workspaceRoot});

  Uri resolveReference(String ref, Uri base) {
    if (ref.startsWith("/") && workspaceRoot != null) {
      return joinPath(workspaceRoot!, [ref]);
    }
    return base.resolve(ref);
  }
}
