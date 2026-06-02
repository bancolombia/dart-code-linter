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
    final child = node.argumentList.arguments.firstWhereOrNull(
      (arg) => arg is NamedArgument && arg.name.lexeme == 'child',
    );

    if (child != null && child is NamedArgument) {
      final expression = child.argumentExpression;

      return expression is InstanceCreationExpression &&
          expression.staticType?.getDisplayString() == 'Container';
    }

    return false;
  }
}
