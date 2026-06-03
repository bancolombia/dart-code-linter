part of 'prefer_using_list_view_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _expressions = <Expression>[];

  Iterable<Expression> get expressions => _expressions;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    if (isSingleChildScrollViewWidget(node.staticType) &&
        _hasColumnChild(node)) {
      _expressions.add(node);
    }
  }

  bool _hasColumnChild(InstanceCreationExpression node) {
    NamedArgumentView? child;
    for (final arg in node.argumentList.arguments) {
      final named = asNamedArgument(arg);
      if (named != null && named.name == 'child') {
        child = named;
        break;
      }
    }
    if (child == null) {
      return false;
    }

    final expression = child.expression;
    if (expression is! InstanceCreationExpression ||
        !isColumnWidget(expression.staticType)) {
      return false;
    }

    final notChildren = expression.argumentList.arguments.firstWhereOrNull(
      (arg) {
        final named = asNamedArgument(arg);
        return named != null && named.name != 'children';
      },
    );

    return notChildren == null;
  }
}
