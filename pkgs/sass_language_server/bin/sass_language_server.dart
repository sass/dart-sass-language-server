import 'dart:io';

import 'package:lsp_server/lsp_server.dart';
import 'package:sass_language_server/sass_language_server.dart';

void main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    print(
        '''sass-language-server [--stdio|--socket=<port>] [--loglevel=<debug|log|info|warn|error|silent>]

Transport options:
  --stdio (default)    Uses stdin and stdout for requests and responses
  --socket=<port>      The language client acts as a socket server, then tells the language server where to connect with this option

Logging options:
  --loglevel=<level>   Sets the verbosity of the log output
''');
    return;
  }

  if (arguments.contains('--version') ||
      arguments.contains('-v') ||
      arguments.contains('-V')) {
    // TODO: automate replacing the version number in the built asset on release
    print('1.0.0');
    return;
  }

  String logLevel = arguments
      .firstWhere((arg) => arg.startsWith('--loglevel='),
          orElse: () => '--loglevel=info')
      .split("=")
      .last;

  String transport = arguments.firstWhere((arg) => arg.startsWith('--socket='),
      orElse: () => '--stdio');

  var fileSystemProvider = LocalFileSystem();
  var server = LanguageServer();

  Connection connection;
  Socket? socket;
  if (transport == '--stdio') {
    connection = Connection(stdin, stdout);
  } else {
    // The client is the one listening to socket connections on the specified port.
    // In other words the language server is a _client_ for the socket transport.
    // The client sets up a socket server on an arbitrary available port and
    // makes sure to pass that port number as --socket=<port> when starting
    // the language server.
    var split = transport.split('=');
    int port = int.parse(split.last);
    socket = await Socket.connect('127.0.0.1', port);
    connection = Connection(socket, socket);
  }

  try {
    exitCode = 1;

    await server.start(
      connection: connection,
      logLevel: logLevel,
      fileSystemProvider: fileSystemProvider,
    );

    // See
    // https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#shutdown
    // https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#exit
    connection.onShutdown(() async {
      socket?.close();
      exitCode = 0;
    });

    connection.onExit(() async {
      exit(exitCode);
    });
  } on Exception catch (_) {
    exit(1);
  }
}
