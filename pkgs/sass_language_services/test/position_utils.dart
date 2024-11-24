import 'package:lsp_server/lsp_server.dart' as lsp;

lsp.Position at({required int line, required int char}) {
  return lsp.Position(character: char, line: line);
}

lsp.Position position(int line, int char) {
  return at(line: line, char: char);
}

lsp.Range range(int startLine, int startChar, int endLine, int endChar) {
  return lsp.Range(
    start: at(line: startLine, char: startChar),
    end: at(line: startLine, char: startChar),
  );
}
