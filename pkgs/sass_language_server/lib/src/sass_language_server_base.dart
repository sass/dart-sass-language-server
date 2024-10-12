import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_server/src/remote_console.dart';
import 'package:sass_language_services/sass_language_services.dart' as sass_ls;

import 'logger.dart';

void listen(
    lsp.Connection connection, sass_ls.FileSystemProvider fileSystemProvider,
    {String? logLevel}) {
  late final lsp.ClientCapabilities clientCapabilities;
  late final sass_ls.LanguageServices ls;
  late final Uri workspaceRoot;
  final Logger log = Logger(RemoteConsole(connection), level: logLevel);

  log.info(
      Intl.message('sass-language-server is running', name: 'logIsRunning'));

  sass_ls.LanguageServerConfiguration applyConfiguration(
      dynamic userConfiguration) {
    log.log('Applying user configuration');

    var configuration =
        sass_ls.LanguageServerConfiguration.from(userConfiguration);
    log.log('Made configuration');
    configuration.workspace.workspaceRoot = workspaceRoot;
    log.log('Setting loglevel');
    log.setLogLevel(configuration.workspace.logLevel);
    log.log('Configuring language services');
    ls.configure(configuration);

    log.log(Intl.message('Applied user configuration',
        name: 'logAppliedUserConfiguration'));

    return configuration;
  }

  Future<void> scan(Uri uri, {int depth = 0}) async {
    const maxDepth = 256; // arbitrary number
    if (depth > maxDepth) {
      return;
    }

    try {
      var uriString = uri.toString();
      var document = ls.cache.getDocument(uriString);
      if (document == null) {
        var text = await fileSystemProvider.readFile(uri);
        document = lsp.TextDocumentItem(
            languageId: uriString.endsWith('.sass')
                ? 'sass'
                : uriString.endsWith('.css')
                    ? 'css'
                    : 'scss',
            text: text,
            uri: uri,
            version: 1);

        ls.parseStylesheet(document);
      }

      var links = await ls.findDocumentLinks(document);
      for (var link in links) {
        if (link.target == null) continue;
        if (link.target!.path.contains("#{")) continue;
        // Our findFiles glob will handle the initial parsing of CSS files
        if (link.target!.path.endsWith(".css")) continue;
        if (link.target!.path.startsWith("sass:")) continue;

        var visited = ls.cache.getDocument(link.target.toString());
        if (visited is lsp.TextDocumentItem) {
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

  connection.onInitialize((params) {
    if (params.rootUri == null) {
      throw Intl.message('rootUri is required in InitializeParams',
          name: 'errInitializeParams',
          desc:
              'Error message that gets thrown if the initialization message is missing the required rootUri parameter');
    }

    clientCapabilities = params.capabilities;
    workspaceRoot = params.rootUri!;

    ls = sass_ls.LanguageServices(
        clientCapabilities: clientCapabilities, fs: fileSystemProvider);

    var serverCapabilities = lsp.ServerCapabilities(
      definitionProvider: lsp.Either2.t1(true),
      documentLinkProvider: lsp.DocumentLinkOptions(resolveProvider: false),
    );

    var result = lsp.InitializeResult(capabilities: serverCapabilities);
    return Future.value(result);
  });

  connection.onNotification("workspace/didChangeConfiguration", (params) async {
    log.info("Got configuration");
    if (params is Map && params['settings'] is Map) {
      log.info('Got settings in configuration params');
      applyConfiguration(params['settings']);
    } else {
      log.info(jsonEncode(params));
    }
  });

  Future<void>? initialScan;
  connection.onInitialized((params) async {
    try {
      initialScan = Future(() async {
        log.debug(Intl.message('Requesting user configuration',
            name: 'logRequestUserConfig'));
        try {
          var response = await connection
              .sendRequest<List<dynamic>>("workspace/configuration", {
            "items": [
              {"section": "editor"},
              {"section": "sass"},
            ]
          });

          applyConfiguration(response);
          log.info(jsonEncode(response));
        } catch (e) {
          log.warn(e.toString());
        }

        var files = await fileSystemProvider.findFiles(
            "**/*.{css,scss,sass,svelte,astro,vue}",
            ls.configuration.workspace.exclude);
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
      print(e..toString());
    }
  });

  connection.listen();
}
