import 'package:lsp_server/lsp_server.dart' as lsp;

lsp.Position at({required int line, required int char}) {
  return lsp.Position(character: char, line: line);
}
