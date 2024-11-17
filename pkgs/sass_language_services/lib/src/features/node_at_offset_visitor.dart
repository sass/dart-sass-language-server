import 'package:sass_api/sass_api.dart' as sass;

class NodeAtOffsetVisitor
    with
        sass.StatementSearchVisitor<sass.AstNode>,
        sass.AstSearchVisitor<sass.AstNode> {
  sass.AstNode? _candidate;
  final int _offset;

  /// Finds the node with the shortest span at [offset].
  NodeAtOffsetVisitor(int offset) : _offset = offset;

  sass.AstNode? _process(sass.AstNode node) {
    var spanContainsOffset =
        node.span.start.offset <= _offset && node.span.end.offset >= _offset;

    if (spanContainsOffset) {
      if (_candidate == null) {
        _candidate = node;
      } else if (node.span.length <= _candidate!.span.length) {
        _candidate = node;
      }
    }

    if (node.span.start.offset > _offset || node is sass.Stylesheet) {
      return _candidate;
    }

    return null;
  }

  @override
  sass.AstNode? visitArgumentInvocation(sass.ArgumentInvocation invocation) {
    return super.visitArgumentInvocation(invocation) ?? _process(invocation);
  }

  @override
  sass.AstNode? visitAtRootRule(sass.AtRootRule node) {
    return super.visitAtRootRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitAtRule(sass.AtRule node) {
    return super.visitAtRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitBinaryOperationExpression(
      sass.BinaryOperationExpression node) {
    return super.visitBinaryOperationExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitBooleanExpression(sass.BooleanExpression node) {
    return super.visitBooleanExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitCallableDeclaration(sass.CallableDeclaration node) {
    return super.visitCallableDeclaration(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitColorExpression(sass.ColorExpression node) {
    return super.visitColorExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitContentBlock(sass.ContentBlock node) {
    return super.visitContentBlock(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitContentRule(sass.ContentRule node) {
    return super.visitContentRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitDebugRule(sass.DebugRule node) {
    return super.visitDebugRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitDeclaration(sass.Declaration node) {
    return super.visitDeclaration(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitEachRule(sass.EachRule node) {
    return super.visitEachRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitErrorRule(sass.ErrorRule node) {
    return super.visitErrorRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitExpression(sass.Expression expression) {
    return super.visitExpression(expression) ?? _process(expression);
  }

  @override
  sass.AstNode? visitExtendRule(sass.ExtendRule node) {
    return super.visitExtendRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitForRule(sass.ForRule node) {
    return super.visitForRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitForwardRule(sass.ForwardRule node) {
    return super.visitForwardRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitFunctionExpression(sass.FunctionExpression node) {
    return super.visitFunctionExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitFunctionRule(sass.FunctionRule node) {
    return super.visitFunctionRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitIfExpression(sass.IfExpression node) {
    return super.visitIfExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitIfRule(sass.IfRule node) {
    return super.visitIfRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitImportRule(sass.ImportRule node) {
    return super.visitImportRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitIncludeRule(sass.IncludeRule node) {
    return super.visitIncludeRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitListExpression(sass.ListExpression node) {
    return super.visitListExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitLoudComment(sass.LoudComment node) {
    return super.visitLoudComment(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitMapExpression(sass.MapExpression node) {
    return super.visitMapExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitMediaRule(sass.MediaRule node) {
    return super.visitMediaRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitMixinRule(sass.MixinRule node) {
    return super.visitMixinRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitNullExpression(sass.NullExpression node) {
    return super.visitNullExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitNumberExpression(sass.NumberExpression node) {
    return super.visitNumberExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitParenthesizedExpression(
      sass.ParenthesizedExpression node) {
    return super.visitParenthesizedExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitReturnRule(sass.ReturnRule node) {
    return super.visitReturnRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitSelectorExpression(sass.SelectorExpression node) {
    return super.visitSelectorExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitSilentComment(sass.SilentComment node) {
    return super.visitSilentComment(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitStringExpression(sass.StringExpression node) {
    return super.visitStringExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitStyleRule(sass.StyleRule node) {
    return super.visitStyleRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitStylesheet(sass.Stylesheet node) {
    return super.visitStylesheet(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitSupportsCondition(sass.SupportsCondition condition) {
    return super.visitSupportsCondition(condition) ?? _process(condition);
  }

  @override
  sass.AstNode? visitSupportsExpression(sass.SupportsExpression node) {
    return super.visitSupportsExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitSupportsRule(sass.SupportsRule node) {
    return super.visitSupportsRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitUnaryOperationExpression(
      sass.UnaryOperationExpression node) {
    return super.visitUnaryOperationExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitUseRule(sass.UseRule node) {
    return super.visitUseRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitValueExpression(sass.ValueExpression node) {
    return super.visitValueExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitVariableDeclaration(sass.VariableDeclaration node) {
    return super.visitVariableDeclaration(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitVariableExpression(sass.VariableExpression node) {
    return super.visitVariableExpression(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitWarnRule(sass.WarnRule node) {
    return super.visitWarnRule(node) ?? _process(node);
  }

  @override
  sass.AstNode? visitWhileRule(sass.WhileRule node) {
    return super.visitWhileRule(node) ?? _process(node);
  }
}
