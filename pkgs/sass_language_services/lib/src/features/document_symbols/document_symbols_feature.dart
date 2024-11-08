import 'package:sass_language_services/sass_language_services.dart';

import '../language_feature.dart';
import 'document_symbols_visitor.dart';
import 'stylesheet_document_symbols.dart';

class DocumentSymbolsFeature extends LanguageFeature {
  DocumentSymbolsFeature({required super.ls});

  StylesheetDocumentSymbols findDocumentSymbols(TextDocument document) {
    var stylesheet = ls.parseStylesheet(document);
    var symbolsVisitor = DocumentSymbolsVisitor(document);
    stylesheet.accept(symbolsVisitor);
    return symbolsVisitor.symbols;
  }
}
