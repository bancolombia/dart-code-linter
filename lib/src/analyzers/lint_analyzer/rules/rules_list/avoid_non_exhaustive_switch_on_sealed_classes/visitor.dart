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
          _isUnguardedWildcard(member.guardedPattern)) {
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
      if (_isUnguardedWildcard(switchCase.guardedPattern)) {
        _fallbackNodes.add(switchCase);
      }
    }
  }

  // A guarded wildcard (`_ when ...`) doesn't satisfy exhaustiveness, so the
  // compiler still enforces the remaining subtypes and there is no fallback
  // to report. A parenthesized wildcard (`(_)`) defeats exhaustiveness the
  // same way a bare `_` does, so it is unwrapped before the check.
  bool _isUnguardedWildcard(GuardedPattern guardedPattern) =>
      _unwrapParentheses(guardedPattern.pattern) is WildcardPattern &&
      guardedPattern.whenClause == null;

  DartPattern _unwrapParentheses(DartPattern pattern) {
    var current = pattern;
    while (current is ParenthesizedPattern) {
      current = current.pattern;
    }

    return current;
  }

  bool _isSealedType(DartType? type) {
    final element = type is InterfaceType ? type.element : null;

    return element is ClassElement && element.isSealed;
  }
}
