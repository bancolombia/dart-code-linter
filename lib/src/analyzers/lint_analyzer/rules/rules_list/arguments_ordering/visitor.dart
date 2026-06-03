part of 'arguments_ordering_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final bool childLast;

  static const _childArg = 'child';
  static const _childrenArg = 'children';
  static const _childArgs = [_childArg, _childrenArg];

  final _issues = <_IssueDetails>[];

  Iterable<_IssueDetails> get issues => _issues;

  _Visitor({required this.childLast});

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    _checkOrder(
      node.argumentList,
      node.constructorName.element!.formalParameters,
    );
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    final element = node.methodName.element;
    if (element is TopLevelFunctionElement) {
      _checkOrder(
        node.argumentList,
        element.formalParameters,
      );
    }
  }

  void _checkOrder(
    ArgumentList argumentList,
    List<FormalParameterElement> parameters,
  ) {
    final sortedArguments = argumentList.arguments.sorted((a, b) {
      final aNamed = asNamedArgument(a);
      final bNamed = asNamedArgument(b);
      if (aNamed == null && bNamed == null) {
        return 0;
      }
      if (aNamed != null && bNamed == null) {
        return 1;
      }
      if (aNamed == null && bNamed != null) {
        return -1;
      }
      if (aNamed != null && bNamed != null) {
        final aName = aNamed.name;
        final bName = bNamed.name;

        if (aName == bName) {
          return 0;
        }

        // We use simplified version for "child" argument check from "sort_child_properties_last" rule
        // https://github.com/dart-lang/linter/blob/1933b2a2969380e5db35d6aec524fb21b0ed028b/lib/src/rules/sort_child_properties_last.dart#L140
        // Hopefully, this will be enough for our current needs.
        if (childLast &&
            _childArgs.any((name) => name == aName || name == bName)) {
          return (_childArgs.contains(aName) && !_childArgs.contains(bName)) ||
                  (aName == _childArg)
              ? 1
              : -1;
        }

        return _parameterIndexByName(parameters, aName)
            .compareTo(_parameterIndexByName(parameters, bName));
      }

      return 0;
    });

    if (argumentList.arguments.toString() != sortedArguments.toString()) {
      _issues.add(
        _IssueDetails(
          argumentList: argumentList,
          replacement: '(${sortedArguments.join(', ')})',
        ),
      );
    }
  }

  static int _parameterIndexByName(
    List<FormalParameterElement> parameters,
    String name,
  ) =>
      parameters.indexWhere((parameter) => parameter.name == name);
}

class _IssueDetails {
  const _IssueDetails({
    required this.argumentList,
    required this.replacement,
  });

  final ArgumentList argumentList;
  final String replacement;
}
