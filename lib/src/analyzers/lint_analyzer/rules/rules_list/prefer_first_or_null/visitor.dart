part of 'prefer_first_or_null_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _expressions = <Expression>[];

  Iterable<Expression> get expressions => _expressions;

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    super.visitPrefixedIdentifier(node);

    final targetType = node.prefix.staticType;

    if (node.identifier.name == 'first' &&
        targetType is InterfaceType &&
        isIterableOrSubclass(targetType)) {
      _expressions.add(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    if (isIterableOrSubclass(node.realTarget?.staticType)) {
      final name = node.methodName.name;

      if (name == 'elementAt') {
        final arg = node.argumentList.arguments.first;

        if (arg is IntegerLiteral && arg.value == 0) {
          _expressions.add(node);
        }
      } else if (name == 'first') {
        _expressions.add(node);
      }
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    super.visitIndexExpression(node);

    if (isListOrSubclass(node.realTarget.staticType)) {
      final index = node.index;

      if (index is IntegerLiteral && index.value == 0) {
        _expressions.add(node);
      }
    }
  }
}
