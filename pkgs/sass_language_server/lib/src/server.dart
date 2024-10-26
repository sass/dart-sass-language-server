import 'dart:convert';
import 'dart:io';

import 'package:lsp_server/lsp_server.dart';
import 'package:sass_language_server/sass_language_server.dart';
import 'package:sass_language_server/src/lsp/remote_console.dart';
import 'package:sass_language_server/src/lsp/text_documents.dart';
import 'package:sass_language_services/sass_language_services.dart';

import 'logger.dart';

class Server implements LanguageServer {
  late Connection _connection;
  late ClientCapabilities _clientCapabilities;
  late LanguageServices _ls;
  late Uri _workspaceRoot;
  late Logger _log;
  late final TextDocuments _documents;

  LanguageServerConfiguration _applyConfiguration(
      Map<String, dynamic> userConfiguration) {
    _log.debug('Applying user configuration');

    var configuration = LanguageServerConfiguration.from(userConfiguration);
    configuration.workspace.workspaceRoot = _workspaceRoot;
    _log.setLogLevel(configuration.workspace.logLevel);
    _ls.configure(configuration);

    _log.debug('Applied user configuration');
    return configuration;
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

  @override
  Future<void> start({
    Transport transport = Transport.stdio,
    required FileSystemProvider fileSystemProvider,
    String logLevel = "info",
    int? port,
  }) async {
    Future<void>? initialScan;

    if (transport == Transport.socket) {
      if (port == null) {
        throw 'Port is required for socket transport';
      }
      var client = await Socket.connect('127.0.0.1', port);
      client.done.then<dynamic>((_) async {
        await stop();
      });
      _connection = Connection(client, client);
    } else {
      _connection = Connection(stdin, stdout);
    }
    _log = Logger(RemoteConsole(_connection), level: logLevel);

    _documents = TextDocuments(
        connection: _connection,
        onDidChangeContent: (params) async {
          try {
            _ls.cache.remove(params.document.uri);
            if (initialScan != null) {
              await initialScan;
            }
            // TODO: doDiagnoastics
          } catch (e) {
            _log.debug(e.toString());
          }
        });

    _log.info('sass-language-server is running');

    Future<void> scan(Uri uri, {int depth = 0}) async {
      const maxDepth = 256; // arbitrary number
      if (depth > maxDepth) {
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
              text);

          _ls.parseStylesheet(document);
        }

        var links = await _ls.findDocumentLinks(document);
        for (var link in links) {
          if (link.target == null) continue;
          if (link.target!.path.contains('#{')) continue;
          // Our findFiles glob will handle the initial parsing of CSS files
          if (link.target!.path.endsWith('.css')) continue;
          if (link.target!.path.startsWith('sass:')) continue;

          var visited = _ls.cache.getDocument(link.target as Uri);
          if (visited is TextDocumentItem) {
            // avoid infinite loop in case of circular references
            continue;
          }

          try {
            await scan(link.target!, depth: depth + 1);
          } catch (e) {
            // do nothing
          }
        }
      } catch (e) {
        // Something went wrong parsing this file, try parsing the others
      }
    }

    _connection.onInitialize((params) {
      if (params.rootUri == null) {
        throw 'rootUri is required in InitializeParams';
      }

      _clientCapabilities = params.capabilities;
      _workspaceRoot = params.rootUri!;

      _ls = LanguageServices(
          clientCapabilities: _clientCapabilities, fs: fileSystemProvider);

      var serverCapabilities = ServerCapabilities(
        documentLinkProvider: DocumentLinkOptions(resolveProvider: false),
        textDocumentSync: Either2.t1(TextDocumentSyncKind.Incremental),
      );

      var result = InitializeResult(capabilities: serverCapabilities);
      return Future.value(result);
    });

    _connection.onNotification('workspace/didChangeConfiguration',
        (params) async {
      if (params is Map && params.asMap['settings'] is Map) {
        _applyConfiguration(params.asMap['settings'] as Map<String, dynamic>);
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

          var files = await fileSystemProvider.findFiles(
              '**/*.{css,scss,sass}', _ls.configuration.workspace.exclude);
          for (var uri in files) {
            if (uri.path.contains('/_')) {
              // Don't include partials in the initial scan.
              // This way we can be reasonably sure that we scan whatever index files there are _before_ we scan
              // partials which may or may not have been forwarded with a prefix.
              continue;
            }
            await scan(uri);
          }
        });
        await initialScan;
        initialScan = null; // all done
      } catch (e) {
        print(e);
      }
    });

    // The spec says we can return null here which I'd prefer to the empty list
    _connection.onDocumentLinks((params) async {
      try {
        var document = _documents.get(params.textDocument.uri);
        if (document == null) return [];

        var configuration = _getLanguageConfiguration(document);
        if (configuration.links.enabled) {
          if (initialScan != null) {
            await initialScan;
          }

          var result = await _ls.findDocumentLinks(document);
          return result;
        } else {
          return [];
        }
      } catch (e) {
        _log.debug(e.toString());
        return [];
      }
    });

    _connection.onShutdown(() async {
      await stop();
    });

    _connection.listen();
  }

  @override
  Future<void> stop() async {
    try {
      _log.debug('Closing connection...');
      await _connection.close();
    } finally {
      _log.debug('Bye');
      exit(0);
    }
  }
}
