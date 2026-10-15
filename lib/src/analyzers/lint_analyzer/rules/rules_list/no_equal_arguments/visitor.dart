part of 'no_equal_arguments_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _arguments = <AstNode>[];

  final Iterable<String> _ignoredParameters;
  final Iterable<String> _ignoredArguments;

  Iterable<AstNode> get arguments => _arguments;

  _Visitor(this._ignoredParameters, this._ignoredArguments);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    _visitArguments(node.argumentList.arguments);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    super.visitFunctionExpressionInvocation(node);

    _visitArguments(node.argumentList.arguments);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    _visitArguments(node.argumentList.arguments);
  }

  void _visitArguments(Iterable<AstNode> arguments) {
    final notIgnoredArguments =
        arguments.whereNot(_isIgnored).cast<AstNode>().toList();

    for (final argument in notIgnoredArguments) {
      final lastAppearance = notIgnoredArguments.lastWhere(
        (arg) {
          final argNamed = asNamedArgument(argument);
          final otherNamed = asNamedArgument(arg);
          if (argNamed != null &&
              otherNamed != null &&
              argNamed.expression is! Literal &&
              otherNamed.expression is! Literal) {
            return haveSameParameterType(
                  argNamed.expression,
                  otherNamed.expression,
                ) &&
                argNamed.expression.toString() ==
                    otherNamed.expression.toString();
          }

          final argExpr = unwrapArgumentExpression(argument);
          final otherExpr = unwrapArgumentExpression(arg);
          if (argExpr == null || otherExpr == null) {
            return false;
          }

          if (_bothLiterals(argExpr, otherExpr)) {
            return argExpr == otherExpr;
          }

          return haveSameParameterType(argExpr, otherExpr) &&
              argExpr.toString() == otherExpr.toString();
        },
        orElse: () => argument,
      );

      if (argument != lastAppearance) {
        _arguments.add(lastAppearance);
      }
    }
  }

  bool _bothLiterals(Expression left, Expression right) =>
      left is Literal && right is Literal ||
      (left is PrefixExpression &&
          left.operand is Literal &&
          right is PrefixExpression &&
          right.operand is Literal);

  bool _isIgnored(AstNode arg) {
    final named = asNamedArgument(arg);
    if (named != null) {
      final expression = named.expression;

      return _ignoredParameters.contains(named.name) ||
          (expression is SimpleIdentifier &&
              _ignoredArguments.contains(expression.name));
    }

    return arg is SimpleIdentifier && _ignoredArguments.contains(arg.name);
  }
}
