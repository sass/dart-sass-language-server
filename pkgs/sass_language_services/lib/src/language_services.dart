import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/document_highlights/document_highlights_feature.dart';
import 'package:sass_language_services/src/features/find_references/find_references_feature.dart';
import 'package:sass_language_services/src/features/go_to_definition/go_to_definition_feature.dart';
import 'package:sass_language_services/src/features/rename/rename_feature.dart';

import 'features/document_links/document_links_feature.dart';
import 'features/document_symbols/document_symbols_feature.dart';
import 'features/workspace_symbols/workspace_symbols_feature.dart';
import 'language_services_cache.dart';

class LanguageServices {
  final LanguageServicesCache cache;
  final lsp.ClientCapabilities clientCapabilities;
  final FileSystemProvider fs;

  LanguageServerConfiguration configuration =
      LanguageServerConfiguration.create(null);

  late final DocumentHighlightsFeature _documentHighlights;
  late final DocumentLinksFeature _documentLinks;
  late final DocumentSymbolsFeature _documentSymbols;
  late final GoToDefinitionFeature _goToDefinition;
  late final FindReferencesFeature _findReferences;
  late final RenameFeature _rename;
  late final WorkspaceSymbolsFeature _workspaceSymbols;

  LanguageServices({
    required this.clientCapabilities,
    required this.fs,
  }) : cache = LanguageServicesCache() {
    _documentHighlights = DocumentHighlightsFeature(ls: this);
    _documentLinks = DocumentLinksFeature(ls: this);
    _documentSymbols = DocumentSymbolsFeature(ls: this);
    _goToDefinition = GoToDefinitionFeature(ls: this);
    _findReferences = FindReferencesFeature(ls: this);
    _rename = RenameFeature(ls: this);
    _workspaceSymbols = WorkspaceSymbolsFeature(ls: this);
  }

  void configure(LanguageServerConfiguration configuration) {
    this.configuration = configuration;
  }

  List<lsp.DocumentHighlight> findDocumentHighlights(
      TextDocument document, lsp.Position position) {
    return _documentHighlights.findDocumentHighlights(document, position);
  }

  Future<List<StylesheetDocumentLink>> findDocumentLinks(
      TextDocument document) {
    return _documentLinks.findDocumentLinks(document);
  }

  List<StylesheetDocumentSymbol> findDocumentSymbols(TextDocument document) {
    return _documentSymbols.findDocumentSymbols(document);
  }

  Future<List<lsp.Location>> findReferences(TextDocument document,
      lsp.Position position, lsp.ReferenceContext context) {
    return _findReferences.findReferences(document, position, context);
  }

  List<lsp.WorkspaceSymbol> findWorkspaceSymbols(String? query) {
    return _workspaceSymbols.findWorkspaceSymbols(query);
  }

  Future<lsp.Location?> goToDefinition(
      TextDocument document, lsp.Position position) {
    return _goToDefinition.goToDefinition(document, position);
  }

  sass.Stylesheet parseStylesheet(TextDocument document) {
    return cache.getStylesheet(document);
  }

  Future<lsp.PrepareRenameResult> prepareRename(
      TextDocument document, lsp.Position position) {
    return _rename.prepareRename(document, position);
  }

  Future<lsp.WorkspaceEdit> rename(
      TextDocument document, lsp.Position position, String newName) {
    return _rename.rename(document, position, newName);
  }
}
