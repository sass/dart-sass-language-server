import 'package:intl/intl.dart';
import 'package:lsp_server/lsp_server.dart';
import 'package:sass_language_services/sass_language_services.dart' as ls;

void listen(Connection connection, ls.FileSystemProvider fileSystemProvider) {
  ClientCapabilities clientCapabilities;
  Uri workspaceRoot;

  connection.onInitialize((params) {
    if (params.rootUri == null) {
      throw "rootUri is required in InitializeParams";
    }

    clientCapabilities = params.capabilities;
    workspaceRoot = params.rootUri!;

    var serverCapabilities = ServerCapabilities(
      definitionProvider: Either2.t1(true),
      documentLinkProvider: DocumentLinkOptions(resolveProvider: false),
    );

    var result = InitializeResult(capabilities: serverCapabilities);
    return Future.value(result);
  });

  Future<void>? initialScan;
  connection.onInitialized((params) async {
    try {
      var configs = await connection
          .sendRequest<ls.LanguageServerConfiguration>(
              "workspace/configuration", {
        "items": [
          {"section": "editor"},
          {"section": "sass"},
        ]
      });
      Intl.defaultLocale = configs.editor.locale;

      await initialScan;
      initialScan = null; // all done
    } catch (e) {
      print(e..toString());
    }
  });

  connection.listen();
}
