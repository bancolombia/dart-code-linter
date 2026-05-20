part of 'avoid_wrapping_in_padding_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _expressions = <Expression>[];

  Iterable<Expression> get expressions => _expressions;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    if (isPaddingWidget(node.staticType) && _hasChildWithPadding(node)) {
      _expressions.add(node);
    }
  }

  bool _hasChildWithPadding(InstanceCreationExpression node) {
    for (final arg in node.argumentList.arguments) {
      final named = asNamedArgument(arg);
      if (named == null || named.name != 'child') {
        continue;
      }
      final expression = named.expression;
      return expression is InstanceCreationExpression &&
          expression.staticType?.getDisplayString() == 'Container';
    }

    return false;
  }
}
