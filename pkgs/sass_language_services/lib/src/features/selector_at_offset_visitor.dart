import 'package:sass_api/sass_api.dart' as sass;

class SelectorAtOffsetVisitor with sass.SelectorSearchVisitor<sass.AstNode> {
  sass.AstNode? candidate;
  final List<sass.AstNode> path = [];
  final int _offset;

  /// Finds the node with the shortest span at [offset],
  /// starting at 0 at the beginning of the selector.
  SelectorAtOffsetVisitor(int offset) : _offset = offset;

  /// Here to allow subclasses to do something with each candidate.
  void processCandidate(sass.AstNode node) {}

  sass.AstNode? _process(sass.AstNode node) {
    var nodeSpan = node.span;
    var nodeStartOffset = nodeSpan.start.offset;
    var nodeEndOffset = nodeSpan.end.offset;
    var containsOffset = nodeStartOffset <= _offset && nodeEndOffset >= _offset;

    if (containsOffset) {
      if (candidate == null) {
        candidate = node;
        path.add(node);
        processCandidate(node);
      } else {
        var nodeLength = nodeEndOffset - nodeStartOffset;
        // store candidateSpan next to _candidate
        var candidateSpan = candidate!.span;
        var candidateLength =
            candidateSpan.end.offset - candidateSpan.start.offset;
        if (nodeLength <= candidateLength) {
          candidate = node;
          path.add(node);
          processCandidate(node);
        }
      }
    }

    if (nodeStartOffset > _offset) {
      // return candidate;
    }

    return null;
  }

  @override
  sass.AstNode? visitSelectorList(sass.SelectorList list) {
    return _process(list) ?? super.visitSelectorList(list);
  }

  @override
  sass.AstNode? visitAttributeSelector(sass.AttributeSelector attribute) {
    return _process(attribute) ?? super.visitAttributeSelector(attribute);
  }

  @override
  sass.AstNode? visitClassSelector(sass.ClassSelector klass) {
    return _process(klass) ?? super.visitClassSelector(klass);
  }

  @override
  sass.AstNode? visitComplexSelector(sass.ComplexSelector complex) {
    return _process(complex) ?? super.visitComplexSelector(complex);
  }

  @override
  sass.AstNode? visitCompoundSelector(sass.CompoundSelector compound) {
    return _process(compound) ?? super.visitCompoundSelector(compound);
  }

  @override
  sass.AstNode? visitIDSelector(sass.IDSelector id) {
    return _process(id) ?? super.visitIDSelector(id);
  }

  @override
  sass.AstNode? visitParentSelector(sass.ParentSelector placeholder) {
    return _process(placeholder) ?? super.visitParentSelector(placeholder);
  }

  @override
  sass.AstNode? visitPlaceholderSelector(sass.PlaceholderSelector placeholder) {
    return _process(placeholder) ?? super.visitPlaceholderSelector(placeholder);
  }

  @override
  sass.AstNode? visitPseudoSelector(sass.PseudoSelector pseudo) {
    return _process(pseudo) ?? super.visitPseudoSelector(pseudo);
  }

  @override
  sass.AstNode? visitTypeSelector(sass.TypeSelector type) {
    return _process(type) ?? super.visitTypeSelector(type);
  }

  @override
  sass.AstNode? visitUniversalSelector(sass.UniversalSelector universal) {
    return _process(universal) ?? super.visitUniversalSelector(universal);
  }
}
