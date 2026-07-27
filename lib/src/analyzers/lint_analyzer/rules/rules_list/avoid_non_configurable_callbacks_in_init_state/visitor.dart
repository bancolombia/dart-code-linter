part of 'avoid_non_configurable_callbacks_in_init_state_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _hardcodedConfigurations = <InstanceCreationExpression>[];

  Iterable<InstanceCreationExpression> get hardcodedConfigurations =>
      _hardcodedConfigurations;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    final type = node.extendsClause?.superclass.type;
    if (type == null || !isWidgetStateOrSubclass(type)) {
      return;
    }

    final body = node.body;
    if (body is! BlockClassBody) {
      return;
    }

    final initState = body.members
        .whereType<MethodDeclaration>()
        .where((member) => member.name.lexeme == 'initState')
        .firstOrNull;

    final initStateBody = initState?.body;
    if (initStateBody is! BlockFunctionBody) {
      return;
    }

    final invocationVisitor = _WidgetFieldInvocationVisitor();
    initStateBody.accept(invocationVisitor);

    for (final invocation in invocationVisitor.invocations) {
      for (final argument in invocation.argumentList.arguments) {
        final expression = unwrapArgumentExpression(argument);
        if (expression is InstanceCreationExpression &&
            _isNonConfigurableCallbackObject(expression)) {
          _hardcodedConfigurations.add(expression);
        }
      }
    }
  }

  bool _isNonConfigurableCallbackObject(InstanceCreationExpression node) {
    final hasNamedCallback =
        node.argumentList.arguments.any(_isNamedFunctionArgument);

    if (!hasNamedCallback) {
      return false;
    }

    final widgetReferenceVisitor = _WidgetReferenceVisitor();
    node.accept(widgetReferenceVisitor);

    return !widgetReferenceVisitor.referencesWidget;
  }

  // Known limitation: a tear-off callback (e.g. `onError: _handleError`) that
  // reads widget fields inside its body is still reported, since only this
  // creation expression is inspected for `widget` references.
  bool _isNamedFunctionArgument(Object? argument) {
    if (!isNamedArgument(argument)) {
      return false;
    }

    final expression = unwrapArgumentExpression(argument);

    return expression?.staticType is FunctionType;
  }
}

/// Collects `widget.<field>.<method>(...)` calls, i.e. method invocations
/// made directly on a field of the enclosing State's `widget`.
class _WidgetFieldInvocationVisitor extends RecursiveAstVisitor<void> {
  final _invocations = <MethodInvocation>[];

  Iterable<MethodInvocation> get invocations => _invocations;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final target = node.target;
    if (target is PrefixedIdentifier && target.prefix.name == 'widget') {
      _invocations.add(node);
    }
  }
}

class _WidgetReferenceVisitor extends RecursiveAstVisitor<void> {
  var _referencesWidget = false;

  bool get referencesWidget => _referencesWidget;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);

    if (node.name == 'widget') {
      _referencesWidget = true;
    }
  }
}
