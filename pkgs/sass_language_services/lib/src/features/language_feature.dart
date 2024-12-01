import 'dart:math';

import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;

import '../../sass_language_services.dart';
import '../utils/uri_utils.dart';
import 'node_at_offset_visitor.dart';

class WorkspaceResult<T> {
  final List<T>? result;
  final Set<String> visited;

  WorkspaceResult(this.result, this.visited);
}

abstract class LanguageFeature {
  late final LanguageServices ls;

  LanguageFeature({required this.ls});

  /// Helper to do some kind of lookup for the import tree of [initialDocument].
  ///
  /// The [callback] is called for each document in the import tree. Documents will only get visited once.
  Future<WorkspaceResult<T>> findInWorkspace<T>(
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
      lazy: lazy,
      hiddenMixinsAndFunctions: [],
      hiddenVariables: [],
      shownMixinsAndFunctions: [],
      shownVariables: [],
      visited: {},
    );
  }

  Future<WorkspaceResult<T>> _findInWorkspace<T>(
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
      required List<String> hiddenMixinsAndFunctions,
      required List<String> hiddenVariables,
      required List<String> shownMixinsAndFunctions,
      required List<String> shownVariables,
      required Set<String> visited,
      String accumulatedPrefix = '',
      bool lazy = false,
      int depth = 0}) async {
    if (visited.contains(currentDocument.uri.toString())) {
      return Future.value(WorkspaceResult([], visited));
    }

    var result = await callback(
      document: currentDocument,
      prefix: accumulatedPrefix,
      hiddenMixinsAndFunctions: hiddenMixinsAndFunctions,
      hiddenVariables: hiddenVariables,
      shownMixinsAndFunctions: shownMixinsAndFunctions,
      shownVariables: shownVariables,
    );

    if (lazy && result != null) {
      return WorkspaceResult(result, visited);
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
      return WorkspaceResult([], visited);
    }

    var linksResult = <T>[];
    for (var link in links) {
      if (link.target == null) {
        continue;
      }

      var target = link.target.toString();
      if (target == currentDocument.uri.toString()) continue;
      if (target.contains('#{')) continue;
      if (target.endsWith('.css')) continue;
      if (target.startsWith('sass:')) continue;

      var uri = link.target!;
      var next = await getTextDocument(uri);

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
        currentDocument: next,
        accumulatedPrefix: prefix,
        hiddenMixinsAndFunctions: hiddenMixinsAndFunctions,
        hiddenVariables: hiddenVariables,
        shownMixinsAndFunctions: shownMixinsAndFunctions,
        shownVariables: shownVariables,
        lazy: lazy,
        visited: visited,
        depth: depth + 1,
      );

      if (linkResult.result != null) {
        linksResult.addAll(linkResult.result!);
      }
    }

    return WorkspaceResult(linksResult, visited);
  }

  /// Returns the value of the variable at [position].
  ///
  /// If the variable references another variable this method will find
  /// that variable's definition and find the original value.
  Future<String?> findVariableValue(
      TextDocument document, lsp.Position position) async {
    return _findValue(document, position);
  }

  Future<String?> _findValue(TextDocument document, lsp.Position position,
      {int depth = 0}) async {
    const maxDepth = 10;
    if (depth > maxDepth) {
      return null;
    }

    var stylesheet = ls.parseStylesheet(document);
    var offset = document.offsetAt(position);
    var visitor = NodeAtOffsetVisitor(offset);
    var result = stylesheet.accept(visitor);
    var variable = result ?? visitor.candidate;

    if (variable is sass.Expression) {
      var isDeclaration = visitor.path.any(
        (node) => node is sass.VariableDeclaration,
      );
      if (isDeclaration) {
        var referencesVariable = variable.toString().contains(r'$');
        if (referencesVariable) {
          return _findValue(
            document,
            document.positionAt(variable.span.start.offset),
            depth: depth + 1,
          );
        } else {
          return variable.toString();
        }
      } else {
        var valueString = variable.toString();
        var dollarIndex = valueString.indexOf(r'$');
        if (dollarIndex != -1) {
          var definition = await ls.goToDefinition(document, position);
          if (definition != null) {
            var definitionDocument = ls.cache.getDocument(definition.uri);
            if (definitionDocument == null) {
              return null;
            }

            if (definitionDocument.uri == document.uri) {
              var definitionOffset = document.offsetAt(definition.range.start);
              if (definitionOffset == variable.span.start.offset) {
                // break early if we're looking up ourselves
                return null;
              }
            }

            return _findValue(
              definitionDocument,
              definition.range.start,
              depth: depth + 1,
            );
          } else {
            return null;
          }
        } else {
          return valueString;
        }
      }
    } else {
      return null;
    }
  }

  Future<TextDocument> getTextDocument(Uri uri) async {
    var textDocument = ls.cache.getDocument(uri);
    if (textDocument == null) {
      // We shouldn't really end up here outside of unit tests.
      // The language server's initial scan should have put all
      // linked documents in the cache already.
      var text = await ls.fs.readFile(uri);
      textDocument = TextDocument(
        uri,
        uri.path.endsWith('.sass')
            ? 'sass'
            : uri.path.endsWith('.css')
                ? 'css'
                : 'scss',
        1,
        text,
      );
      ls.parseStylesheet(textDocument);
    }
    return textDocument;
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
