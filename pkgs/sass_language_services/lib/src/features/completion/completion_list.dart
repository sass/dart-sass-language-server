import 'package:lsp_server/lsp_server.dart' as lsp;

/// A mutable variant of [lsp.CompletionList].
class CompletionList {
  bool isIncomplete;
  List<lsp.CompletionItem> items;
  lsp.CompletionListItemDefaults itemDefaults;

  CompletionList({
    required this.isIncomplete,
    required this.itemDefaults,
    required this.items,
  });
}
