import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:source_span/source_span.dart';

lsp.Range toRange(FileSpan span) {
  return lsp.Range(
      start: lsp.Position(
        line: span.start.line,
        character: span.start.column,
      ),
      end: lsp.Position(line: span.end.line, character: span.end.column));
}

lsp.Range selectorNameRange(
    sass.StyleRule node, sass.CompoundSelector selector) {
  // The selector span seems to be relative to node, not to the file.
  return lsp.Range(
    start: lsp.Position(
      line: node.span.start.line + selector.span.start.line,
      character: node.span.start.column + selector.span.start.column,
    ),
    end: lsp.Position(
      line: node.span.start.line + selector.span.end.line,
      character: node.span.start.column + selector.span.end.column,
    ),
  );
}
