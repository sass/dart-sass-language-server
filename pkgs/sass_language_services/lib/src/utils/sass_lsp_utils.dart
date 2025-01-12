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
    {required FileSpan node, required FileSpan selector}) {
  // The selector span seems to be relative to node, not to the file.
  return lsp.Range(
    start: lsp.Position(
      line: node.start.line + selector.start.line,
      character: node.start.column + selector.start.column,
    ),
    end: lsp.Position(
      line: node.start.line + selector.end.line,
      character: node.start.column + selector.end.column,
    ),
  );
}

lsp.Range forwardVisibilityRange(sass.ForwardRule node, String name) {
  var span = node.span;
  var nameIndex = span.text.indexOf(
    name,
    span.start.offset + node.urlSpan.end.offset,
  );

  var selectionRange = lsp.Range(
    start: lsp.Position(
      line: span.start.line,
      character: span.start.column + nameIndex,
    ),
    end: lsp.Position(
      line: span.start.line,
      character: span.start.column + nameIndex + name.length,
    ),
  );
  return selectionRange;
}

bool isInRange({required lsp.Position position, required lsp.Range range}) {
  return range.start.line <= position.line &&
      range.start.character <= position.character &&
      range.end.line >= position.line &&
      range.end.character >= position.character;
}

bool isSameLocation(lsp.Location a, lsp.Location b) {
  return a.uri.toString() == b.uri.toString() && isSameRange(a.range, b.range);
}

bool isSameRange(lsp.Range a, lsp.Range b) {
  return a.start.line == b.start.line &&
      a.start.character == b.start.character &&
      a.end.line == b.end.line &&
      a.end.character == b.end.character;
}

lsp.Either2<lsp.MarkupContent, String> asMarkdown(String content) {
  return lsp.Either2.t1(
    lsp.MarkupContent(
      kind: lsp.MarkupKind.Markdown,
      value: content,
    ),
  );
}

lsp.Either2<lsp.MarkupContent, String> asPlaintext(String content) {
  return lsp.Either2.t1(
    lsp.MarkupContent(
      kind: lsp.MarkupKind.PlainText,
      value: content,
    ),
  );
}
