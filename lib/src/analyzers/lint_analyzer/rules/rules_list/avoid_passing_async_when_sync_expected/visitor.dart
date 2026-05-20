part of 'avoid_passing_async_when_sync_expected_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _invalidArguments = <AstNode>[];

  Iterable<AstNode> get invalidArguments => _invalidArguments;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    _handleInvalidArguments(node.argumentList);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    _handleInvalidArguments(node.argumentList);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    super.visitFunctionExpressionInvocation(node);
    _handleInvalidArguments(node.argumentList);
  }

  void _handleInvalidArguments(ArgumentList arguments) {
    for (final argument in arguments.arguments) {
      final expression = unwrapArgumentExpression(argument);
      final argumentType = expression?.staticType;
      final parameterType = argument.correspondingParameter?.type;
      if (argumentType is FunctionType && parameterType is FunctionType) {
        if (argumentType.returnType.isDartAsyncFuture &&
            !_hasValidFutureType(parameterType.returnType)) {
          _invalidArguments.add(argument);
        }
      }
    }
  }

  bool _hasValidFutureType(DartType type) =>
      type.isDartAsyncFuture ||
      type.isDartAsyncFutureOr ||
      type is DynamicType ||
      type.isDartCoreObject;
}
