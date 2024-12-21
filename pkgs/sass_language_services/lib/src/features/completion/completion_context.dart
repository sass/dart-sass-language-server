import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';

import '../../configuration/language_configuration.dart';

class CompletionContext {
  final lsp.Position position;
  final String currentWord;
  final String lineBeforePosition;
  final int offset;
  final lsp.Range defaultReplaceRange;
  final TextDocument document;
  final sass.Stylesheet stylesheet;
  final CompletionConfiguration configuration;

  CompletionContext({
    required this.offset,
    required this.position,
    required this.currentWord,
    required this.defaultReplaceRange,
    required this.document,
    required this.stylesheet,
    required this.configuration,
    required this.lineBeforePosition,
  });
}
