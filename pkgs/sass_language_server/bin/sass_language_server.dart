import 'dart:io';
import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_server/sass_language_server.dart' as server;

void main(List<String> arguments) {
  if (arguments.contains('--version') ||
      arguments.contains('-v') ||
      arguments.contains('-V')) {
    // TODO: read CLI version from pubspec.yaml
    print('1.0.0');
    return;
  }

  if (arguments.contains('--help') || arguments.contains('-h')) {
    print(
        'sass-language-server [--loglevel <debug|log|info|warn|error|silent>]');
    return;
  }

  String? logLevel;
  int levelArg = arguments.indexOf('--loglevel');
  if (levelArg != -1) {
    logLevel = arguments[levelArg + 1];
  }

  var connection = lsp.Connection(stdin, stdout);
  var provider = server.LocalFileSystem();
  server.listen(connection, provider, logLevel: logLevel);
}
