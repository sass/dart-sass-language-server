import 'dart:math';

import 'package:sass_api/sass_api.dart' as sass;

import '../../sass_language_services.dart';
import '../utils/uri_utils.dart';

abstract class LanguageFeature {
  late final LanguageServices ls;

  LanguageFeature({required this.ls});

  /// Helper to do some kind of lookup for the import tree of [initialDocument].
  ///
  /// Starting with [initialDocument], the [visitor] is run on each document in
  /// the link tree. Keeps internal track of prefixes, show and hide on `@forward`.
  /// `@use` is only followed in the initial document.
  Future<List<T>?> findInWorkspace<T extends List<T>>(
      {required sass.AstSearchVisitor<T> visitor,
      required TextDocument initialDocument,
      bool lazy = false,
      int depth = 0}) async {
    return _findInWorkspace(
        visitor: visitor,
        initialDocument: initialDocument,
        currentDocument: initialDocument,
        depth: depth);
  }

  Future<List<T>?> _findInWorkspace<T extends List<T>>(
      {required sass.AstSearchVisitor<T> visitor,
      required TextDocument initialDocument,
      required TextDocument currentDocument,
      String accumulatedPrefix = '',
      List<String> hiddenMixinsAndFunctions = const [],
      List<String> hiddenVariables = const [],
      List<String> shownMixinsAndFunctions = const [],
      List<String> shownVariables = const [],
      Set<String> visited = const {},
      int depth = 0}) async {
    if (visited.contains(currentDocument.uri.toString())) {
      return Future.value([]);
    }

    var document = ls.parseStylesheet(currentDocument);
    var result = document.accept(visitor);
    if (result != null) {
      return result;
    } else {
      result = <T>[] as T?;
    }

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
        visitor: visitor,
        initialDocument: initialDocument,
        currentDocument: currentDocument,
        accumulatedPrefix: prefix,
        hiddenMixinsAndFunctions: hiddenMixinsAndFunctions,
        hiddenVariables: hiddenVariables,
        shownMixinsAndFunctions: shownMixinsAndFunctions,
        shownVariables: shownVariables,
        visited: visited,
        depth: depth + 1,
      );

      if (linkResult != null) {
        result!.addAll(linkResult);
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
