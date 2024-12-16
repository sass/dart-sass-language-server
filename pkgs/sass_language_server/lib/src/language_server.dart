import 'package:lsp_server/lsp_server.dart';
import 'package:sass_language_server/src/lsp/remote_console.dart';
import 'package:sass_language_server/src/lsp/text_documents.dart';
import 'package:sass_language_services/sass_language_services.dart';

import 'logger.dart';
import 'utils/uri.dart';

enum Transport { stdio, socket }

const scannerMaxDepth = 256;

class LanguageServer {
  late Connection _connection;
  late ClientCapabilities _clientCapabilities;
  late LanguageServices _ls;
  late Uri _workspaceRoot;
  late Logger _log;
  late final TextDocuments _documents;
  LanguageServerConfiguration? _configuration;

  void _applyConfiguration(Map<String, dynamic> userConfiguration) {
    _log.debug('Applying user configuration');

    if (_configuration case var configuration?) {
      _log.debug('Update existing configuration');
      // updates only contain the section that is updated ("editor" or "sass")
      configuration.update(userConfiguration);
    } else {
      _log.debug('First time creating configuration');
      _configuration = LanguageServerConfiguration.create(userConfiguration);
    }

    _configuration!.workspace.workspaceRoot = _workspaceRoot;
    _log.debug('Setting new log level ${_configuration!.workspace.logLevel}');
    _log.setLogLevel(_configuration!.workspace.logLevel);
    _ls.configure(_configuration!);

    _log.debug('Applied user configuration');
  }

  LanguageConfiguration _getLanguageConfiguration(TextDocument document) {
    var languageId = document.languageId;
    switch (languageId) {
      case 'css':
        return _ls.configuration.css;
      case 'scss':
        return _ls.configuration.scss;
      case 'sass':
        return _ls.configuration.sass;
    }
    throw 'Unsupported language ID $languageId';
  }

  Future<void> start({
    required Connection connection,
    required FileSystemProvider fileSystemProvider,
    String logLevel = "info",
    int? port,
  }) async {
    _connection = connection;

    Future<void>? initialScan;

    _log = Logger(RemoteConsole(_connection), level: logLevel);

    _documents = TextDocuments(
        connection: _connection,
        onDidChangeContent: (params) async {
          try {
            // Update the cache with the new version of the document.
            _ls.cache.onDocumentChanged(params.document);
            if (initialScan != null) {
              await initialScan;
            }
            // TODO: doDiagnostics
          } on Exception catch (e) {
            _log.debug(e.toString());
          }
        });

    _log.info('sass-language-server is running');

    Future<void> scan(Uri uri, {int depth = 0}) async {
      if (depth > scannerMaxDepth) {
        return;
      }

      try {
        var document = _ls.cache.getDocument(uri);
        if (document == null) {
          var text = await fileSystemProvider.readFile(uri);
          document = TextDocument(
            uri,
            uri.path.endsWith('.sass')
                ? 'sass'
                : uri.path.endsWith('.css')
                    ? 'css'
                    : 'scss',
            1,
            text,
          );

          _ls.parseStylesheet(document);
        }

        var links = await _ls.findDocumentLinks(document);
        for (var link in links) {
          if (link.target == null) continue;

          var target = link.target.toString();
          if (target.contains('#{')) continue;
          // Our findFiles glob will handle the initial parsing of CSS files
          if (target.endsWith('.css')) continue;
          // Sass built-ins are not files we can scan.
          if (target.startsWith('sass:')) continue;

          var visited = _ls.cache.getDocument(link.target as Uri);
          if (visited != null) {
            // avoid infinite loop in case of circular references
            continue;
          }

          try {
            await scan(link.target!, depth: depth + 1);
          } on Exception catch (e) {
            // continue
            _log.debug(e.toString());
          }
        }
      } on Exception catch (e) {
        // Something went wrong parsing this file, try parsing the others
        _log.debug(e.toString());
      }
    }

    _connection.onInitialize((params) async {
      if (params.rootUri == null) {
        throw 'rootUri is required in InitializeParams';
      }

      _clientCapabilities = params.capabilities;

      if (params.rootPath case var rootPath?) {
        _workspaceRoot = filePathToUri(rootPath);
      } else if (params.rootUri case var rootUri?) {
        _workspaceRoot = rootUri;
      } else {
        throw 'Got neither rootPath or rootUri in initialize params';
      }

      _log.debug('workspace root $_workspaceRoot');

      _ls = LanguageServices(
        clientCapabilities: _clientCapabilities,
        fs: fileSystemProvider,
      );

      var serverCapabilities = ServerCapabilities(
        definitionProvider: Either2.t1(true),
        documentHighlightProvider: Either2.t1(true),
        documentLinkProvider: DocumentLinkOptions(resolveProvider: false),
        documentSymbolProvider: Either2.t1(true),
        foldingRangeProvider: Either3.t1(true),
        hoverProvider: Either2.t1(true),
        referencesProvider: Either2.t1(true),
        renameProvider: Either2.t2(RenameOptions(prepareProvider: true)),
        selectionRangeProvider: Either3.t1(true),
        textDocumentSync: Either2.t1(TextDocumentSyncKind.Incremental),
        workspaceSymbolProvider: Either2.t1(true),
      );

      var result = InitializeResult(capabilities: serverCapabilities);
      return result;
    });

    _connection.onNotification('workspace/didChangeConfiguration',
        (params) async {
      if (params.value is Map && params.value['settings'] is Map) {
        _applyConfiguration(params.value['settings'] as Map<String, dynamic>);
      } else {
        _log.info(
            'workspace/didChangeConfiguration did not get expected parameters');
      }
    });

    _connection.onInitialized((params) async {
      try {
        initialScan = Future(() async {
          _log.debug('Requesting user configuration');
          try {
            var response = await _connection
                .sendRequest<List<dynamic>>('workspace/configuration', {
              'items': [
                {'section': 'editor'},
                {'section': 'sass'},
              ]
            });
            var settings = {
              "editor": response.first,
              "sass": response.last,
            };
            _applyConfiguration(settings);
          } catch (e) {
            _log.warn(e.toString());
          }

          _log.debug('Searching workspace for files');
          var files = await fileSystemProvider.findFiles('**.{css,scss,sass}',
              root: _workspaceRoot.toFilePath(),
              exclude: _ls.configuration.workspace.exclude);
          _log.debug('Found ${files.length} files in workspace');
          for (var uri in files) {
            if (uri.path.contains('/_')) {
              // Don't include partials in the initial scan.
              // This way we can be reasonably sure that we scan whatever index files there are _before_ we scan
              // partials which may or may not have been forwarded with a prefix.
              continue;
            }
            _log.debug('Scanning $uri');
            await scan(uri);
          }
        });
        await initialScan;
        initialScan = null; // all done
        _log.debug('Finished initial scan of workspace');
      } on Exception catch (e) {
        _log.error(e.toString());
      }
    });

    _connection.onDefinition((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) return null;

        var configuration = _getLanguageConfiguration(document);
        if (configuration.definition.enabled) {
          if (initialScan != null) {
            await initialScan;
          }
          var result = await _ls.goToDefinition(document, params.position);
          if (result is Location) {
            return Either3.t1(result);
          } else {
            return null;
          }
        } else {
          return null;
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return null;
      }
    });

    _connection.onDocumentHighlight((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) return [];

        var configuration = _getLanguageConfiguration(document);
        if (configuration.highlights.enabled) {
          if (initialScan != null) {
            await initialScan;
          }

          var result = _ls.findDocumentHighlights(document, params.position);
          return result;
        } else {
          return [];
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return [];
      }
    });

    _connection.onDocumentLinks((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) return [];

        var configuration = _getLanguageConfiguration(document);
        if (configuration.documentLinks.enabled) {
          if (initialScan != null) {
            await initialScan;
          }

          var result = await _ls.findDocumentLinks(document);
          return result;
        } else {
          return [];
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return [];
      }
    });

    // TODO: upstream allowing DocumentSymbol here
    Future<List<DocumentSymbol>> onDocumentSymbol(dynamic params) async {
      try {
        var documentSymbolParams =
            DocumentSymbolParams.fromJson(params.value as Map<String, Object?>);

        var document = _documents.get(documentSymbolParams.textDocument.uri);
        if (document == null) return [];

        var configuration = _getLanguageConfiguration(document);
        if (configuration.documentSymbols.enabled) {
          if (initialScan != null) {
            await initialScan;
          }

          var result = _ls.findDocumentSymbols(document);
          return Future.value(result);
        } else {
          return [];
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return [];
      }
    }

    _connection.peer
        .registerMethod('textDocument/documentSymbol', onDocumentSymbol);

    _connection.onHover((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) {
          // TODO: Would like to return null instead of empty content.
          return Hover(contents: Either2.t2(""));
        }

        var configuration = _getLanguageConfiguration(document);
        if (configuration.hover.enabled) {
          var result = await _ls.hover(document, params.position);
          return result ?? Hover(contents: Either2.t2(""));
        } else {
          return Hover(contents: Either2.t2(""));
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return Hover(contents: Either2.t2(""));
      }
    });

    _connection.onReferences((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) return [];

        var configuration = _getLanguageConfiguration(document);
        if (configuration.references.enabled) {
          if (initialScan != null) {
            await initialScan;
          }

          var result = await _ls.findReferences(
            document,
            params.position,
            params.context,
          );
          return result;
        } else {
          return [];
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return [];
      }
    });

    _connection.onPrepareRename((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) {
          return Either2.t2(
            Either3.t2(
              PrepareRenameResult2(defaultBehavior: true),
            ),
          );
        }

        var configuration = _getLanguageConfiguration(document);
        if (configuration.rename.enabled) {
          if (initialScan != null) {
            await initialScan;
          }

          var result = await _ls.prepareRename(
            document,
            params.position,
          );
          return Either2.t2(result);
        } else {
          return Either2.t2(
            Either3.t2(
              PrepareRenameResult2(defaultBehavior: true),
            ),
          );
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return Either2.t2(
          Either3.t2(
            PrepareRenameResult2(defaultBehavior: true),
          ),
        );
      }
    });

    _connection.onRenameRequest((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) {
          return WorkspaceEdit();
        }

        var configuration = _getLanguageConfiguration(document);
        if (configuration.rename.enabled) {
          if (initialScan != null) {
            await initialScan;
          }

          var result = await _ls.rename(
            document,
            params.position,
            params.newName,
          );
          return result;
        } else {
          return WorkspaceEdit();
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return WorkspaceEdit();
      }
    });

    _connection.onFoldingRanges((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) {
          return [];
        }

        var configuration = _getLanguageConfiguration(document);
        if (configuration.foldingRanges.enabled) {
          var result = _ls.getFoldingRanges(document);
          return result;
        } else {
          return [];
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return [];
      }
    });

    _connection.onSelectionRanges((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) {
          return [];
        }

        var configuration = _getLanguageConfiguration(document);
        if (configuration.selectionRanges.enabled) {
          var result = _ls.getSelectionRanges(
            document,
            params.positions,
          );
          return result;
        } else {
          return [];
        }
      } on Exception catch (e) {
        _log.debug(e.toString());
        return [];
      }
    });

    // TODO: add this handler upstream
    Future<List<WorkspaceSymbol>> onWorkspaceSymbol(dynamic params) async {
      try {
        var query = (params.value as Map<String, Object?>)['query'] as String?;

        if (initialScan != null) {
          await initialScan;
        }

        var result = _ls.findWorkspaceSymbols(query);
        return result;
      } on Exception catch (e) {
        _log.debug(e.toString());
        return [];
      }
    }

    _connection.peer.registerMethod('workspace/symbol', onWorkspaceSymbol);

    _connection.listen();
  }
}
