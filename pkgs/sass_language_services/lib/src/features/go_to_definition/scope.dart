import '../document_symbols/stylesheet_document_symbol.dart';

class Scope {
  Scope? parent;
  final List<Scope> children = [];
  final int offset;
  final int length;

  final _symbols = <StylesheetDocumentSymbol>[];

  Scope({required this.offset, required this.length});

  void addChild(Scope scope) {
    children.add(scope);
    scope.setParent(this);
  }

  void setParent(Scope scope) {
    parent = scope;
  }

  Scope? findScope({required int offset, int length = 0}) {
    if ((this.offset <= offset &&
            this.offset + this.length > offset + length) ||
        (this.offset == offset && this.length == length)) {
      return findInScope(offset: offset, length: length);
    }
    return null;
  }

  Scope findInScope({required int offset, int length = 0}) {
    var scopeAtOffset = children.firstWhere(
        (scope) =>
            scope.offset <= offset &&
            scope.offset + scope.length > offset + length,
        orElse: () => this);

    if (scopeAtOffset == this) {
      return this;
    }

    return scopeAtOffset.findInScope(offset: offset, length: length);
  }

  void addSymbol(StylesheetDocumentSymbol symbol) {
    _symbols.add(symbol);
  }

  StylesheetDocumentSymbol? getSymbol(
      {required String name, required ReferenceKind referenceKind}) {
    for (var symbol in _symbols) {
      if (symbol.referenceKind == referenceKind && symbol.name == name) {
        return symbol;
      }
    }
    return null;
  }

  List<StylesheetDocumentSymbol> getSymbols() {
    return _symbols;
  }
}
