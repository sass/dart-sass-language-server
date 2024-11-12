import 'dart:math';

import '../../sass_language_services.dart';
import '../utils/uri_utils.dart';

abstract class LanguageFeature {
  late final LanguageServices ls;

  LanguageFeature({required this.ls});

  /// Helper to do some kind of lookup for the import tree of [initialDocument].
  ///
  /// The [callback] is called for each document in the import tree. Documents will only get visited once.
  Future<List<T>?> findInWorkspace<T>(
      {required Future<List<T>?> Function({
        required TextDocument document,
        required String prefix,
        required List<String> hiddenMixinsAndFunctions,
        required List<String> hiddenVariables,
        required List<String> shownMixinsAndFunctions,
        required List<String> shownVariables,
      }) callback,
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

  Future<List<T>?> _findInWorkspace<T>(
      {required Future<List<T>?> Function({
        required TextDocument document,
        required String prefix,
        required List<String> hiddenMixinsAndFunctions,
        required List<String> hiddenVariables,
        required List<String> shownMixinsAndFunctions,
        required List<String> shownVariables,
      }) callback,
      required TextDocument initialDocument,
      required TextDocument currentDocument,
      String accumulatedPrefix = '',
      List<String> hiddenMixinsAndFunctions = const [],
      List<String> hiddenVariables = const [],
      List<String> shownMixinsAndFunctions = const [],
      List<String> shownVariables = const [],
      Set<String> visited = const {},
      bool lazy = false,
      int depth = 0}) async {
    if (visited.contains(currentDocument.uri.toString())) {
      return Future.value([]);
    }

    var result = await callback(
        document: currentDocument,
        prefix: accumulatedPrefix,
        hiddenMixinsAndFunctions: hiddenMixinsAndFunctions,
        hiddenVariables: hiddenVariables,
        shownMixinsAndFunctions: shownMixinsAndFunctions,
        shownVariables: shownVariables);

    if (lazy && result != null) {
      return result;
    }

    result ??= [];

    visited.add(currentDocument.uri.toString());

    var allLinks = await ls.findDocumentLinks(currentDocument);

    // Filter out links we want to follow.
    var links = allLinks.where((link) {
      if (link.type == LinkType.use) {
        // Don't follow uses beyond the first, since symbols from those aren't available to us anyway.
        return depth == 0;
      }
      if (link.type == LinkType.import) {
        // Don't follow imports, the whole point here is to use the module system.
        return false;
      }
      return true;
    });

    if (links.isEmpty) {
      return result;
    }

    for (var link in links) {
      if (link.target == null ||
          link.target.toString() == currentDocument.uri.toString()) {
        continue;
      }

      var next = ls.cache.getDocument(link.target!);
      if (next == null) {
        // We shouldn't really end up here. If so, the feature's handler in
        // the server should await the initial scan.
        continue;
      }

      var prefix = accumulatedPrefix;
      if (link.type == LinkType.forward) {
        if (link.prefix != null) {
          prefix += link.prefix!;
        }

        if (link.hiddenMixinsAndFunctions != null) {
          hiddenMixinsAndFunctions.addAll(link.hiddenMixinsAndFunctions!);
        }
        if (link.hiddenVariables != null) {
          hiddenVariables.addAll(link.hiddenVariables!);
        }

        if (link.shownMixinsAndFunctions != null) {
          shownMixinsAndFunctions.addAll(link.shownMixinsAndFunctions!);
        }
        if (link.shownVariables != null) {
          shownVariables.addAll(link.shownVariables!);
        }
      }

      var linkResult = await _findInWorkspace(
        callback: callback,
        initialDocument: initialDocument,
        currentDocument: currentDocument,
        accumulatedPrefix: prefix,
        hiddenMixinsAndFunctions: hiddenMixinsAndFunctions,
        hiddenVariables: hiddenVariables,
        shownMixinsAndFunctions: shownMixinsAndFunctions,
        shownVariables: shownVariables,
        lazy: lazy,
        visited: visited,
        depth: depth + 1,
      );

      if (linkResult != null) {
        result.addAll(linkResult);
      }
    }

    return result;
  }

  DocumentContext getDocumentContext() {
    return DocumentContext(
        workspaceRoot: ls.configuration.workspace.workspaceRoot);
  }

  String getFileName(Uri uri) {
    var asString = uri.toString();
    var lastSlash = asString.lastIndexOf('/');
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
    if (ref.startsWith('/') && workspaceRoot != null) {
      return joinPath(workspaceRoot!, [ref]);
    }
    return base.resolve(ref);
  }
}
