import 'package:sass_api/sass_api.dart' as sass;

class NodeAtOffsetVisitor implements sass.AstSearchVisitor<sass.AstNode> {
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

    if (node.span.end.offset > _offset) {
      return _candidate;
    }

    return null;
  }

  @override
  sass.AstNode? visitArgumentInvocation(sass.ArgumentInvocation invocation) {
    return _process(invocation);
  }

  @override
  sass.AstNode? visitAtRootRule(sass.AtRootRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitAtRule(sass.AtRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitBinaryOperationExpression(
      sass.BinaryOperationExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitBooleanExpression(sass.BooleanExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitCallableDeclaration(sass.CallableDeclaration node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitChildren(List<sass.Statement> children) {
    for (var node in children) {
      var result = _process(node);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  @override
  sass.AstNode? visitColorExpression(sass.ColorExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitContentBlock(sass.ContentBlock node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitContentRule(sass.ContentRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitDebugRule(sass.DebugRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitDeclaration(sass.Declaration node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitEachRule(sass.EachRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitErrorRule(sass.ErrorRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitExpression(sass.Expression expression) {
    return _process(expression);
  }

  @override
  sass.AstNode? visitExtendRule(sass.ExtendRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitForRule(sass.ForRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitForwardRule(sass.ForwardRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitFunctionExpression(sass.FunctionExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitFunctionRule(sass.FunctionRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitIfExpression(sass.IfExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitIfRule(sass.IfRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitImportRule(sass.ImportRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitIncludeRule(sass.IncludeRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitInterpolatedFunctionExpression(
      sass.InterpolatedFunctionExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitInterpolation(sass.Interpolation interpolation) {
    return _process(interpolation);
  }

  @override
  sass.AstNode? visitListExpression(sass.ListExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitLoudComment(sass.LoudComment node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitMapExpression(sass.MapExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitMediaRule(sass.MediaRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitMixinRule(sass.MixinRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitNullExpression(sass.NullExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitNumberExpression(sass.NumberExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitParenthesizedExpression(
      sass.ParenthesizedExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitReturnRule(sass.ReturnRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitSelectorExpression(sass.SelectorExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitSilentComment(sass.SilentComment node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitStringExpression(sass.StringExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitStyleRule(sass.StyleRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitStylesheet(sass.Stylesheet node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitSupportsCondition(sass.SupportsCondition condition) {
    return _process(condition);
  }

  @override
  sass.AstNode? visitSupportsExpression(sass.SupportsExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitSupportsRule(sass.SupportsRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitUnaryOperationExpression(
      sass.UnaryOperationExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitUseRule(sass.UseRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitValueExpression(sass.ValueExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitVariableDeclaration(sass.VariableDeclaration node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitVariableExpression(sass.VariableExpression node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitWarnRule(sass.WarnRule node) {
    return _process(node);
  }

  @override
  sass.AstNode? visitWhileRule(sass.WhileRule node) {
    return _process(node);
  }
}
