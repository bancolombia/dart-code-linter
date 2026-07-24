part of 'avoid_non_exhaustive_switch_on_sealed_classes_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _fallbackNodes = <AstNode>[];

  Iterable<AstNode> get fallbackNodes => _fallbackNodes;

  @override
  void visitSwitchStatement(SwitchStatement node) {
    super.visitSwitchStatement(node);

    if (!_isSealedType(node.expression.staticType)) {
      return;
    }

    for (final member in node.members) {
      if (member is SwitchDefault) {
        _fallbackNodes.add(member);
      } else if (member is SwitchPatternCase &&
          member.guardedPattern.pattern is WildcardPattern) {
        _fallbackNodes.add(member);
      }
    }
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    super.visitSwitchExpression(node);

    if (!_isSealedType(node.expression.staticType)) {
      return;
    }

    for (final switchCase in node.cases) {
      if (switchCase.guardedPattern.pattern is WildcardPattern) {
        _fallbackNodes.add(switchCase);
      }
    }
  }

  bool _isSealedType(DartType? type) {
    final element = type is InterfaceType ? type.element : null;

    return element is ClassElement && element.isSealed;
  }
}
