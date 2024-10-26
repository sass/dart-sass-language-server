import 'package:lsp_server/lsp_server.dart' as lsp;

// See https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#messageType for levels and values
const _error = 1;
const _warn = 2;
const _info = 3;
const _log = 4;
const _debug = 5;

/// Interface for [window/logmessage](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#window_logMessage).
class RemoteConsole {
  late lsp.Connection _connection;

  RemoteConsole(lsp.Connection connection) {
    _connection = connection;
  }

  void error(String message) {
    send(_error, message);
  }

  void warn(String message) {
    send(_warn, message);
  }

  void info(String message) {
    send(_info, message);
  }

  void log(String message) {
    send(_log, message);
  }

  void debug(String message) {
    send(_debug, message);
  }

  void send(int type, String message) {
    try {
      _connection.sendNotification(
          'window/logMessage', {"type": type, "message": message});
    } catch (e) {
      print(e);
    }
  }
}
