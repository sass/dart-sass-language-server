import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/completion/completion_feature.dart';
import 'package:sass_language_services/src/features/document_highlights/document_highlights_feature.dart';
import 'package:sass_language_services/src/features/find_references/find_references_feature.dart';
import 'package:sass_language_services/src/features/folding_ranges/folding_ranges_feature.dart';
import 'package:sass_language_services/src/features/go_to_definition/go_to_definition_feature.dart';
import 'package:sass_language_services/src/features/hover/hover_feature.dart';
import 'package:sass_language_services/src/features/rename/rename_feature.dart';
import 'package:sass_language_services/src/features/selection_ranges/selection_ranges_feature.dart';

import 'features/document_links/document_links_feature.dart';
import 'features/document_symbols/document_symbols_feature.dart';
import 'features/workspace_symbols/workspace_symbols_feature.dart';
import 'language_services_cache.dart';

/// The main public API for Sass language features.
class LanguageServices {
  final LanguageServicesCache cache;

  /// @internal
  final lsp.ClientCapabilities clientCapabilities;

  /// @internal
  final FileSystemProvider fs;

  LanguageServerConfiguration configuration =
      LanguageServerConfiguration.create(null);

  late final CompletionFeature _completion;
  late final DocumentHighlightsFeature _documentHighlights;
  late final DocumentLinksFeature _documentLinks;
  late final DocumentSymbolsFeature _documentSymbols;
  late final FoldingRangesFeature _foldingRanges;
  late final FindReferencesFeature _findReferences;
  late final GoToDefinitionFeature _goToDefinition;
  late final HoverFeature _hover;
  late final RenameFeature _rename;
  late final SelectionRangesFeature _selectionRanges;
  late final WorkspaceSymbolsFeature _workspaceSymbols;

  LanguageServices({
    required this.clientCapabilities,
    required this.fs,
  }) : cache = LanguageServicesCache() {
    _completion = CompletionFeature(ls: this);
    _documentHighlights = DocumentHighlightsFeature(ls: this);
    _documentLinks = DocumentLinksFeature(ls: this);
    _documentSymbols = DocumentSymbolsFeature(ls: this);
    _findReferences = FindReferencesFeature(ls: this);
    _foldingRanges = FoldingRangesFeature(ls: this);
    _goToDefinition = GoToDefinitionFeature(ls: this);
    _hover = HoverFeature(ls: this);
    _rename = RenameFeature(ls: this);
    _selectionRanges = SelectionRangesFeature(ls: this);
    _workspaceSymbols = WorkspaceSymbolsFeature(ls: this);
  }

  void configure(LanguageServerConfiguration configuration) {
    this.configuration = configuration;
  }

  /// Get a response for the [completion proposal](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_completion) request.
  ///
  /// Editors use this response to show relevant suggestions when typing.
  Future<lsp.CompletionList> doComplete(
      TextDocument document, lsp.Position position) {
    return _completion.doComplete(document, position);
  }

  /// Get a response for the [document highlights](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_documentHighlight) request.
  ///
  /// Editors use this response to highlight occurences
  /// of the symbol or word at a given [position] in the [document].
  List<lsp.DocumentHighlight> findDocumentHighlights(
      TextDocument document, lsp.Position position) {
    return _documentHighlights.findDocumentHighlights(document, position);
  }

  /// Get a response for the [document links](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_documentLink) request.
  ///
  /// Editors use this response to open the correct document
  /// when interacting with a `@use`, `@forward` or `@import`
  /// in the [document].
  Future<List<StylesheetDocumentLink>> findDocumentLinks(
      TextDocument document) {
    return _documentLinks.findDocumentLinks(document);
  }

  /// Get a response for the [document symbols](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_documentSymbol) request.
  List<StylesheetDocumentSymbol> findDocumentSymbols(TextDocument document) {
    return _documentSymbols.findDocumentSymbols(document);
  }

  /// Builds scopes and a list of symbols in those scopes starting at the global scope.
  ScopedSymbols getScopedSymbols(TextDocument document) {
    return _documentSymbols.getScopedSymbols(document);
  }

  /// Get a response for the [references](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_references) request.
  Future<List<lsp.Location>> findReferences(TextDocument document,
      lsp.Position position, lsp.ReferenceContext context) {
    return _findReferences.findReferences(document, position, context);
  }

  /// Get a response for the [workspace symbols](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#workspace_symbol) request.
  List<lsp.WorkspaceSymbol> findWorkspaceSymbols(String? query) {
    return _workspaceSymbols.findWorkspaceSymbols(query);
  }

  /// Get a response for the [folding ranges](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_foldingRange) request.
  List<lsp.FoldingRange> getFoldingRanges(TextDocument document) {
    return _foldingRanges.getFoldingRanges(document);
  }

  /// Get a response for the [selection ranges](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_selectionRange) request.
  List<lsp.SelectionRange> getSelectionRanges(
      TextDocument document, List<lsp.Position> positions) {
    return _selectionRanges.getSelectionRanges(document, positions);
  }

  /// Get a response for the [go to definition](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_definition) request.
  Future<lsp.Location?> goToDefinition(
      TextDocument document, lsp.Position position) {
    return _goToDefinition.goToDefinition(document, position);
  }

  /// Get a response for the [hover](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_hover) request.
  Future<lsp.Hover?> hover(TextDocument document, lsp.Position position) {
    return _hover.doHover(document, position);
  }

  /// Get a Stylesheet AST for a given [document].
  ///
  /// Uses the [cache] to avoid reparsing if the document
  /// has not changed since this function was last called.
  sass.Stylesheet parseStylesheet(TextDocument document) {
    return cache.getStylesheet(document);
  }

  /// Get a response for the [prepare rename](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_prepareRename) request.
  Future<lsp.PrepareRenameResult> prepareRename(
      TextDocument document, lsp.Position position) {
    return _rename.prepareRename(document, position);
  }

  /// Get a response for the [rename](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_rename) request.
  ///
  /// The response includes edits for all references to the symbol at [position].
  Future<lsp.WorkspaceEdit> rename(
      TextDocument document, lsp.Position position, String newName) {
    return _rename.rename(document, position, newName);
  }
}
