import 'package:sass_language_services/src/features/document_symbols/stylesheet_document_symbol.dart';

class StylesheetDocumentSymbols {
  /// Sass variable declarations.
  final variables = <StylesheetDocumentSymbol>[];

  /// Sass function declarations.
  final functions = <StylesheetDocumentSymbol>[];

  /// Sass mixin declarations.
  final mixins = <StylesheetDocumentSymbol>[];

  /// Placeholder selectors this document declares.
  final placeholders = <StylesheetDocumentSymbol>[];

  /// Placeholder selectors this document @extends.
  final placeholderUsages = <StylesheetDocumentSymbol>[];

  /// Declared CSS selectors.
  final selectors = <StylesheetDocumentSymbol>[];

  /// Declared CSS variables.
  final cssVariables = <StylesheetDocumentSymbol>[];

  final keyframeIdentifiers = <StylesheetDocumentSymbol>[];

  final fontFaces = <StylesheetDocumentSymbol>[];

  final mediaQueries = <StylesheetDocumentSymbol>[];

  List<StylesheetDocumentSymbol> get symbols => [
        ...variables,
        ...functions,
        ...mixins,
        ...placeholders,
        ...placeholderUsages,
        ...selectors,
        ...cssVariables,
        ...keyframeIdentifiers,
        ...fontFaces,
        ...mediaQueries
      ];
}
