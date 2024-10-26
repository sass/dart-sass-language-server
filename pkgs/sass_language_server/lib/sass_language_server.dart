import 'package:sass_language_services/sass_language_services.dart';

export 'src/local_file_system.dart';
import 'src/server.dart';

enum Transport { stdio, socket }

abstract class LanguageServer {
  factory LanguageServer() = Server;

  Future<void> start(
      {Transport transport = Transport.stdio,
      required FileSystemProvider fileSystemProvider,
      String logLevel = "info",
      int? port});

  Future<void> stop();
}
