import 'package:sass_language_server/sass_language_server.dart';

void main(List<String> arguments) async {
  if (arguments.contains('--version') ||
      arguments.contains('-v') ||
      arguments.contains('-V')) {
    // TODO: read CLI version from pubspec.yaml
    print('1.0.0');
    return;
  }

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

  String logLevel = arguments
      .firstWhere((arg) => arg.startsWith('--loglevel='),
          orElse: () => '--loglevel=info')
      .split("=")
      .last;

  var server = LanguageServer();

  String transport = arguments.firstWhere((arg) => arg.startsWith('--socket='),
      orElse: () => '--stdio');

  if (transport == '--stdio') {
    await server.start(logLevel: logLevel);
  } else {
    // The client is the one listening to socket connections on the specified port.
    // In other words the language server is a _client_ for the socket transport.
    // The client sets up a socket server on an arbitrary available port and
    // makes sure to pass that port number as --socket=<port> when starting
    // the language server.

    var split = transport.split('=');
    int port = int.parse(split.last);
    await server.start(
        transport: Transport.socket, port: port, logLevel: logLevel);
  }
}
