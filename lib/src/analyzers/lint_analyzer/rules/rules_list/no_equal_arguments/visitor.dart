part of 'no_equal_arguments_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _arguments = <Argument>[];

  final Iterable<String> _ignoredParameters;
  final Iterable<String> _ignoredArguments;

  Iterable<Argument> get arguments => _arguments;

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

  void _visitArguments(Iterable<Argument> arguments) {
    final notIgnoredArguments = arguments.whereNot(_isIgnored).toList();

    for (final argument in notIgnoredArguments) {
      final argumentExpression = argument.argumentExpression;
      final lastAppearance = notIgnoredArguments.lastWhere((arg) {
        final argExpression = arg.argumentExpression;

        if (argument is NamedArgument &&
            arg is NamedArgument &&
            argumentExpression is! Literal &&
            argExpression is! Literal) {
          return haveSameParameterType(argumentExpression, argExpression) &&
              argumentExpression.toString() == argExpression.toString();
        }

        if (_bothLiterals(argumentExpression, argExpression)) {
          return argumentExpression == argExpression;
        }

        return haveSameParameterType(argumentExpression, argExpression) &&
            argumentExpression.toString() == argExpression.toString();
      });

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

  bool _isIgnored(Argument arg) {
    if (arg is NamedArgument) {
      final expression = arg.argumentExpression;

      return _ignoredParameters.contains(arg.name.lexeme) ||
          (expression is SimpleIdentifier &&
              _ignoredArguments.contains(expression.name));
    }

    final expression = arg.argumentExpression;

    return expression is SimpleIdentifier &&
        _ignoredArguments.contains(expression.name);
  }
}
