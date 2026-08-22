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

    final members = classBodyMembers(node);
    if (members == null) {
      return;
    }

    final initState = members
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
            _isNonConfigurableCallbackObject(expression, members)) {
          _hardcodedConfigurations.add(expression);
        }
      }
    }
  }

  bool _isNonConfigurableCallbackObject(
    InstanceCreationExpression node,
    List<ClassMember> classBody,
  ) {
    final hasNamedCallback =
        node.argumentList.arguments.any(_isNamedFunctionArgument);

    if (!hasNamedCallback) {
      return false;
    }

    return !_mayReferenceWidget(node, classBody);
  }

  bool _isNamedFunctionArgument(Object? argument) {
    if (!isNamedArgument(argument)) {
      return false;
    }

    final expression = unwrapArgumentExpression(argument);

    return expression?.staticType is FunctionType;
  }

  /// Whether the configuration [node] can reach a `widget` reference: directly
  /// in its own expression tree, or through methods of the same State class
  /// (tear-off callbacks and calls inside callback literals, followed
  /// transitively). A function-typed argument that is neither a literal nor a
  /// method of this class cannot be inspected here and is conservatively
  /// treated as referencing the widget.
  bool _mayReferenceWidget(
    InstanceCreationExpression node,
    List<ClassMember> classBody,
  ) {
    if (_referencesWidget(node)) {
      return true;
    }

    final methods = <String, MethodDeclaration>{
      for (final member in classBody)
        if (member is MethodDeclaration) member.name.lexeme: member,
    };

    for (final expression in argumentExpressions(node.argumentList)) {
      final isOpaqueCallback = expression is! FunctionExpression &&
          expression.staticType is FunctionType &&
          !(expression is SimpleIdentifier &&
              methods.containsKey(expression.name));
      if (isOpaqueCallback) {
        return true;
      }
    }

    final collector = _MethodReferenceCollector(methods.keys.toSet());
    node.accept(collector);

    final pending = collector.referencedNames.toList();
    final visited = <String>{};
    while (pending.isNotEmpty) {
      final name = pending.removeLast();
      if (!visited.add(name)) {
        continue;
      }

      final methodBody = methods[name]!.body;
      if (_referencesWidget(methodBody)) {
        return true;
      }

      final bodyCollector = _MethodReferenceCollector(methods.keys.toSet());
      methodBody.accept(bodyCollector);
      pending.addAll(bodyCollector.referencedNames);
    }

    return false;
  }

  bool _referencesWidget(AstNode node) {
    final visitor = _WidgetReferenceVisitor();
    node.accept(visitor);

    return visitor.referencesWidget;
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

/// Collects identifiers that match a method name of the enclosing State
/// class, i.e. tear-offs of and calls to same-class methods.
class _MethodReferenceCollector extends RecursiveAstVisitor<void> {
  _MethodReferenceCollector(this._knownMethodNames);

  final Set<String> _knownMethodNames;
  final referencedNames = <String>{};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);

    if (_knownMethodNames.contains(node.name)) {
      referencedNames.add(node.name);
    }
  }
}
