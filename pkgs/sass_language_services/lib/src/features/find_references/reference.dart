import 'package:lsp_server/lsp_server.dart' as lsp;

import '../document_symbols/stylesheet_document_symbol.dart';

class Reference {
  final lsp.Location location;
  final String name;
  final ReferenceKind kind;

  /// Used in the [Prepare rename response](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_prepareRename).
  ///
  /// If true it's up to the client to compute a rename range.
  /// For example, an editor may rename all occurences of [name] in the
  /// current document.
  final bool defaultBehavior;

  Reference({
    required this.name,
    required this.location,
    required this.kind,
    this.defaultBehavior = false,
  });
}
