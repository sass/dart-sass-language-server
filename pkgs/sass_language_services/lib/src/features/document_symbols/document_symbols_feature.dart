import 'package:sass_language_services/sass_language_services.dart';

import '../language_feature.dart';
import 'document_symbols_visitor.dart';

class DocumentSymbolsFeature extends LanguageFeature {
  DocumentSymbolsFeature({required super.ls});

  List<StylesheetDocumentSymbol> findDocumentSymbols(TextDocument document) {
    var stylesheet = ls.parseStylesheet(document);

    var symbolsVisitor = DocumentSymbolsVisitor();
    stylesheet.accept(symbolsVisitor);

    return symbolsVisitor.symbols;
  }

  ScopedSymbols getScopedSymbols(TextDocument document) {
    var stylesheet = ls.parseStylesheet(document);

    var symbols = ls.cache.getScopedSymbols(document) ??
        ScopedSymbols(
          stylesheet,
          document.languageId == 'sass' ? Dialect.indented : Dialect.scss,
        );
    ls.cache.setScopedSymbols(document, symbols);

    return symbols;
  }
}
