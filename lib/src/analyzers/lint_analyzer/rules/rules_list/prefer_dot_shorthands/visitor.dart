part of 'prefer_dot_shorthands_rule.dart';

typedef _Candidate = ({AstNode node, String replacement});

class _Visitor extends RecursiveAstVisitor<void> {
  final _candidates = <_Candidate>[];

  Iterable<_Candidate> get candidates => _candidates;

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    super.visitPrefixedIdentifier(node);

    final prefixElement = node.prefix.element;
    if (prefixElement is! InterfaceElement) {
      return;
    }

    if (_matchesContextType(node, prefixElement)) {
      _candidates.add((
        node: node,
        replacement: '.${node.identifier.name}',
      ));
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final target = node.target;
    if (target is! SimpleIdentifier || node.typeArguments != null) {
      return;
    }

    final targetElement = target.element;
    if (targetElement is! InterfaceElement) {
      return;
    }

    if (_matchesContextType(node, targetElement)) {
      _candidates.add((
        node: node,
        replacement: '.${node.methodName.name}${node.argumentList.toSource()}',
      ));
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final constructorName = node.constructorName;
    final name = constructorName.name;
    if (node.keyword != null || constructorName.type.typeArguments != null) {
      return;
    }

    final typeElement = constructorName.type.element;
    if (typeElement is! InterfaceElement) {
      return;
    }

    if (_matchesContextType(node, typeElement)) {
      _candidates.add((
        node: node,
        replacement:
            '.${name?.name ?? 'new'}${node.argumentList.toSource()}',
      ));
    }
  }

  bool _matchesContextType(Expression node, InterfaceElement declaredType) {
    final contextElement = _contextTypeElement(node);

    return contextElement != null && contextElement == declaredType;
  }

  InterfaceElement? _contextTypeElement(Expression node) {
    final parameter = correspondingParameterOf(node);
    if (parameter != null) {
      // A parameter declared with a type parameter (e.g. `T value`) may get
      // its type substituted from this very argument; a shorthand would
      // remove the inference source and no longer compile.
      if (parameter.baseElement.type is TypeParameterType) {
        return null;
      }

      return _classElement(parameter.type);
    }

    final parent = node.parent;
    if (parent is VariableDeclaration && parent.initializer == node) {
      final declarationList = parent.parent;
      if (declarationList is VariableDeclarationList) {
        final typeAnnotation = declarationList.type;
        if (typeAnnotation != null) {
          return _classElement(typeAnnotation.type);
        }
      }
    }

    if (parent is ConstantPattern && parent.expression == node) {
      return _classElement(_switchScrutineeOf(parent)?.staticType);
    }

    return null;
  }

  Expression? _switchScrutineeOf(ConstantPattern pattern) {
    final guardedPattern = pattern.parent;
    if (guardedPattern is! GuardedPattern) {
      return null;
    }

    final caseNode = guardedPattern.parent;
    if (caseNode is SwitchExpressionCase) {
      final switchExpression = caseNode.parent;

      return switchExpression is SwitchExpression
          ? switchExpression.expression
          : null;
    }

    if (caseNode is SwitchPatternCase) {
      final switchStatement = caseNode.parent;

      return switchStatement is SwitchStatement
          ? switchStatement.expression
          : null;
    }

    return null;
  }

  InterfaceElement? _classElement(DartType? type) =>
      type is InterfaceType ? type.element : null;
}
