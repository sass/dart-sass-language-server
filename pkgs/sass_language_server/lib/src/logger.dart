import 'remote_console.dart';

const _silent = 0;
const _error = 1;
const _warn = 2;
const _info = 3;
const _log = 4;
const _debug = 5;

int levelToRank(String level) {
  switch (level) {
    case "error":
      return _error;
    case "warn":
      return _warn;
    case "log":
      return _log;
    case "debug":
      return _debug;
    case "silent":
      return _silent;
    case "info":
    default:
      return _info;
  }
}

class Logger {
  late RemoteConsole _console;
  late int _level;

  Logger(RemoteConsole console, {String? level}) {
    _console = console;
    _level = levelToRank(level ?? 'info');
  }

  void setLogLevel(String level) {
    _level = levelToRank(level);
  }

  void error(String message) {
    if (_level >= _error) {
      _console.error(message);
    }
  }

  void warn(String message) {
    if (_level >= _warn) {
      _console.warn(message);
    }
  }

  void info(String message) {
    if (_level >= _info) {
      _console.info(message);
    }
  }

  void log(String message) {
    if (_level >= _log) {
      _console.log(message);
    }
  }

  void debug(String message) {
    if (_level >= _debug) {
      _console.debug(message);
    }
  }
}
