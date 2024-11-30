import 'package:sass_api/sass_api.dart' as sass;

sass.AstNode? getNodeAtOffset(sass.ParentStatement node, int offset) {
  if (node.span.start.offset > offset || offset > node.span.end.offset) {
    return null;
  }
  var visitor = NodeAtOffsetVisitor(offset);
  var result = node.accept(visitor);
  // The visitor might have reached the end of the syntax tree,
  // in which case result is null. We still might have a candidate.
  return result ?? visitor.candidate;
}

class NodeAtOffsetVisitor
    with
        sass.StatementSearchVisitor<sass.AstNode>,
        sass.AstSearchVisitor<sass.AstNode> {
  sass.AstNode? candidate;
  final int _offset;

  /// Finds the node with the shortest span at [offset].
  NodeAtOffsetVisitor(int offset) : _offset = offset;

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
        processCandidate(node);
      } else {
        var nodeLength = nodeEndOffset - nodeStartOffset;
        // store candidateSpan next to _candidate
        var candidateSpan = candidate!.span;
        var candidateLength =
            candidateSpan.end.offset - candidateSpan.start.offset;
        if (nodeLength <= candidateLength) {
          candidate = node;
          processCandidate(node);
        }
      }
    }

    if (nodeStartOffset > _offset) {
      return candidate;
    }

    return null;
  }

  @override
  sass.AstNode? visitArgumentInvocation(sass.ArgumentInvocation invocation) {
    return _process(invocation) ?? super.visitArgumentInvocation(invocation);
  }

  @override
  sass.AstNode? visitAtRootRule(sass.AtRootRule node) {
    return _process(node) ?? super.visitAtRootRule(node);
  }

  @override
  sass.AstNode? visitAtRule(sass.AtRule node) {
    return _process(node) ?? super.visitAtRule(node);
  }

  @override
  sass.AstNode? visitBinaryOperationExpression(
      sass.BinaryOperationExpression node) {
    return _process(node) ?? super.visitBinaryOperationExpression(node);
  }

  @override
  sass.AstNode? visitBooleanExpression(sass.BooleanExpression node) {
    return _process(node) ?? super.visitBooleanExpression(node);
  }

  @override
  sass.AstNode? visitCallableDeclaration(sass.CallableDeclaration node) {
    return _process(node) ?? super.visitCallableDeclaration(node);
  }

  @override
  sass.AstNode? visitColorExpression(sass.ColorExpression node) {
    return _process(node) ?? super.visitColorExpression(node);
  }

  @override
  sass.AstNode? visitContentBlock(sass.ContentBlock node) {
    return _process(node) ?? super.visitContentBlock(node);
  }

  @override
  sass.AstNode? visitContentRule(sass.ContentRule node) {
    return _process(node) ?? super.visitContentRule(node);
  }

  @override
  sass.AstNode? visitDebugRule(sass.DebugRule node) {
    return _process(node) ?? super.visitDebugRule(node);
  }

  @override
  sass.AstNode? visitDeclaration(sass.Declaration node) {
    return _process(node) ?? super.visitDeclaration(node);
  }

  @override
  sass.AstNode? visitEachRule(sass.EachRule node) {
    return _process(node) ?? super.visitEachRule(node);
  }

  @override
  sass.AstNode? visitErrorRule(sass.ErrorRule node) {
    return _process(node) ?? super.visitErrorRule(node);
  }

  @override
  sass.AstNode? visitExpression(sass.Expression expression) {
    return _process(expression) ?? super.visitExpression(expression);
  }

  @override
  sass.AstNode? visitExtendRule(sass.ExtendRule node) {
    return _process(node) ?? super.visitExtendRule(node);
  }

  @override
  sass.AstNode? visitForRule(sass.ForRule node) {
    return _process(node) ?? super.visitForRule(node);
  }

  @override
  sass.AstNode? visitForwardRule(sass.ForwardRule node) {
    return _process(node) ?? super.visitForwardRule(node);
  }

  @override
  sass.AstNode? visitFunctionExpression(sass.FunctionExpression node) {
    return _process(node) ?? super.visitFunctionExpression(node);
  }

  @override
  sass.AstNode? visitFunctionRule(sass.FunctionRule node) {
    return _process(node) ?? super.visitFunctionRule(node);
  }

  @override
  sass.AstNode? visitIfExpression(sass.IfExpression node) {
    return _process(node) ?? super.visitIfExpression(node);
  }

  @override
  sass.AstNode? visitIfRule(sass.IfRule node) {
    return _process(node) ?? super.visitIfRule(node);
  }

  @override
  sass.AstNode? visitImportRule(sass.ImportRule node) {
    return _process(node) ?? super.visitImportRule(node);
  }

  @override
  sass.AstNode? visitIncludeRule(sass.IncludeRule node) {
    return _process(node) ?? super.visitIncludeRule(node);
  }

  @override
  sass.AstNode? visitListExpression(sass.ListExpression node) {
    return _process(node) ?? super.visitListExpression(node);
  }

  @override
  sass.AstNode? visitLoudComment(sass.LoudComment node) {
    return _process(node) ?? super.visitLoudComment(node);
  }

  @override
  sass.AstNode? visitMapExpression(sass.MapExpression node) {
    return _process(node) ?? super.visitMapExpression(node);
  }

  @override
  sass.AstNode? visitMediaRule(sass.MediaRule node) {
    return _process(node) ?? super.visitMediaRule(node);
  }

  @override
  sass.AstNode? visitMixinRule(sass.MixinRule node) {
    return _process(node) ?? super.visitMixinRule(node);
  }

  @override
  sass.AstNode? visitNullExpression(sass.NullExpression node) {
    return _process(node) ?? super.visitNullExpression(node);
  }

  @override
  sass.AstNode? visitNumberExpression(sass.NumberExpression node) {
    return _process(node) ?? super.visitNumberExpression(node);
  }

  @override
  sass.AstNode? visitParenthesizedExpression(
      sass.ParenthesizedExpression node) {
    return _process(node) ?? super.visitParenthesizedExpression(node);
  }

  @override
  sass.AstNode? visitReturnRule(sass.ReturnRule node) {
    return _process(node) ?? super.visitReturnRule(node);
  }

  @override
  sass.AstNode? visitSelectorExpression(sass.SelectorExpression node) {
    return _process(node) ?? super.visitSelectorExpression(node);
  }

  @override
  sass.AstNode? visitSilentComment(sass.SilentComment node) {
    return _process(node) ?? super.visitSilentComment(node);
  }

  @override
  sass.AstNode? visitStringExpression(sass.StringExpression node) {
    return _process(node) ?? super.visitStringExpression(node);
  }

  @override
  sass.AstNode? visitStyleRule(sass.StyleRule node) {
    return _process(node) ?? super.visitStyleRule(node);
  }

  @override
  sass.AstNode? visitStylesheet(sass.Stylesheet node) {
    return _process(node) ?? super.visitStylesheet(node);
  }

  @override
  sass.AstNode? visitSupportsCondition(sass.SupportsCondition condition) {
    return _process(condition) ?? super.visitSupportsCondition(condition);
  }

  @override
  sass.AstNode? visitSupportsExpression(sass.SupportsExpression node) {
    return _process(node) ?? super.visitSupportsExpression(node);
  }

  @override
  sass.AstNode? visitSupportsRule(sass.SupportsRule node) {
    return _process(node) ?? super.visitSupportsRule(node);
  }

  @override
  sass.AstNode? visitUnaryOperationExpression(
      sass.UnaryOperationExpression node) {
    return _process(node) ?? super.visitUnaryOperationExpression(node);
  }

  @override
  sass.AstNode? visitUseRule(sass.UseRule node) {
    return _process(node) ?? super.visitUseRule(node);
  }

  @override
  sass.AstNode? visitValueExpression(sass.ValueExpression node) {
    return _process(node) ?? super.visitValueExpression(node);
  }

  @override
  sass.AstNode? visitVariableDeclaration(sass.VariableDeclaration node) {
    return _process(node) ?? super.visitVariableDeclaration(node);
  }

  @override
  sass.AstNode? visitVariableExpression(sass.VariableExpression node) {
    return _process(node) ?? super.visitVariableExpression(node);
  }

  @override
  sass.AstNode? visitWarnRule(sass.WarnRule node) {
    return _process(node) ?? super.visitWarnRule(node);
  }

  @override
  sass.AstNode? visitWhileRule(sass.WhileRule node) {
    return _process(node) ?? super.visitWhileRule(node);
  }
}
