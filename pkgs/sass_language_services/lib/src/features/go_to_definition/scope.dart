import '../document_symbols/stylesheet_document_symbol.dart';

class Scope {
  Scope? parent;
  final List<Scope> children = [];
  final int offset;
  final int length;

  final _symbols = <StylesheetDocumentSymbol>[];

  /// Starting at [offset] and going for [lenght] characters, inclusive.
  Scope({required this.offset, required this.length});

  void addChild(Scope scope) {
    children.add(scope);
    scope.setParent(this);
  }

  void setParent(Scope scope) {
    parent = scope;
  }

  Scope? findScope({required int offset, int length = 0}) {
    var scopeContainsOffset = (this.offset <= offset &&
            this.offset + this.length > offset + length) ||
        (this.offset == offset && this.length == length);

    if (scopeContainsOffset) {
      return findInScope(offset: offset, length: length);
    }

    return null;
  }

  /// Assumes a sorted [list], where [matcher] would return false
  /// for all elements before it returns true. This lets us do a bisect
  /// to quickly find the first element, as opposed to a linear firstWhere.
  int _first<T>(List<T> list, bool Function(T item) matcher) {
    if (list.isEmpty) {
      return 0;
    }

    var low = 0;
    var high = list.length;

    while (low < high) {
      var half = ((low + high) / 2).floor();
      if (matcher(list[half])) {
        high = half;
      } else {
        low = half + 1;
      }
    }

    return low;
  }

  Scope findInScope({required int offset, int length = 0}) {
    var end = offset + length;
    var scopeIndex = _first(
      children,
      (scope) => scope.offset > end,
    );

    if (scopeIndex == 0) {
      return this;
    }

    var candidate = children.elementAt(scopeIndex - 1);
    var containsOffset = candidate.offset <= offset &&
        candidate.offset + candidate.length >= offset + length;
    if (containsOffset) {
      return candidate.findInScope(offset: offset, length: length);
    }

    return this;
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
