import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart';
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/node_at_offset_visitor.dart';

import '../find_references/find_references_feature.dart';

class RenameFeature extends FindReferencesFeature {
  RenameFeature({required super.ls});

  Future<lsp.PrepareRenameResult> prepareRename(
      TextDocument document, lsp.Position position) async {
    var stylesheet = ls.parseStylesheet(document);
    var node = getNodeAtOffset(stylesheet, document.offsetAt(position));
    if (node == null) {
      return lsp.Either3.t2(lsp.PrepareRenameResult2(defaultBehavior: true));
    }
    var name = getNodeName(node);
    if (name == null) {
      return lsp.Either3.t2(lsp.PrepareRenameResult2(defaultBehavior: true));
    }

    var result = await internalFindReferences(
      document,
      position,
      lsp.ReferenceContext(includeDeclaration: true),
    );

    if (result.references.isEmpty || result.references.first.defaultBehavior) {
      return lsp.Either3.t2(lsp.PrepareRenameResult2(defaultBehavior: true));
    }

    var span = node.span;
    if (node is SassReference) {
      span = node.nameSpan;
    }
    if (node is SassDeclaration) {
      span = node.nameSpan;
    }

    var excludeOffset = 0;
    if (node is VariableExpression || node is VariableDeclaration) {
      // Exclude the $ of the variable and % of the placeholder
      // from the rename range since they're required anyway.
      excludeOffset += 1;
    } else if (node is ExtendRule) {
      excludeOffset += 'extends %'.length;
    }

    if (result.definition case var definition?) {
      // Exclude any @forward prefix.
      if (name != definition.name) {
        var diff = name.length - definition.name.length;
        excludeOffset += diff;
      }
    }

    var renameRange = lsp.Range(
      start: document.positionAt(
        span.start.offset + excludeOffset,
      ),
      end: document.positionAt(span.end.offset),
    );

    return lsp.Either3.t1(
      lsp.PlaceholderAndRange(
        placeholder: document.getText(range: renameRange),
        range: renameRange,
      ),
    );
  }

  Future<lsp.WorkspaceEdit> rename(
      TextDocument document, lsp.Position position, String newName) async {
    var result = await internalFindReferences(
      document,
      position,
      lsp.ReferenceContext(includeDeclaration: true),
    );

    var edits = <String, List<lsp.TextEdit>>{};
    for (var reference in result.references) {
      var name = reference.name;
      var location = reference.location;
      var list = edits.putIfAbsent(
        location.uri.toString(),
        () => [],
      );

      var excludeOffset = 0;
      if (reference.kind == ReferenceKind.placeholderSelector ||
          reference.kind == ReferenceKind.variable) {
        // Exclude the % of the placeholder from the rename range since it's required anyway.
        excludeOffset += 1;
      }

      if (result.definition case var definition?) {
        // Exclude any @forward prefix.
        if (name != definition.name) {
          var diff = name.length - definition.name.length;
          excludeOffset += diff;
        }
      }

      var range = location.range;
      var newRange = lsp.Range(
        start: lsp.Position(
          line: range.start.line,
          character: range.start.character + excludeOffset,
        ),
        end: range.end,
      );

      list.add(lsp.TextEdit(newText: newName, range: newRange));
    }

    var changes = edits.map<Uri, List<lsp.TextEdit>>(
      (key, value) => MapEntry(Uri.parse(key), value),
    );

    return lsp.WorkspaceEdit(changes: changes);
  }
}
