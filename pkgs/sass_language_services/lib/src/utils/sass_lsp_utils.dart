import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:source_span/source_span.dart';

lsp.Range toRange(FileSpan span) {
  return lsp.Range(
      start: lsp.Position(
        line: span.start.line,
        character: span.start.column,
      ),
      end: lsp.Position(line: span.end.line, character: span.end.column));
}
