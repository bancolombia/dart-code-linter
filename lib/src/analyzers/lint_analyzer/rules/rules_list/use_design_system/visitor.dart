part of 'use_design_system_item_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final Map<String, _ReplacementSuggestion> _configurations;
  final List<Issue> issues = [];
  final UseDesignSystemItemRule rule;
  final InternalResolvedUnitResult source;

  _Visitor(this._configurations, this.rule, this.source);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final widgetName = node.constructorName.type.element2?.displayName;
    if (widgetName == null || !_configurations.containsKey(widgetName)) {
      return;
    }

    final suggestion = _configurations[widgetName];
    if (suggestion == null) {
      return;
    }

    final libraryUri = node.constructorName.element?.library2.toString() ?? '';
    if (libraryUri.isEmpty || !libraryUri.contains(suggestion.fromPackage)) {
      return;
    }

    issues.add(
      createIssue(
        rule: rule,
        location: nodeLocation(node: node, source: source),
        message:
            '${suggestion.insteadOf} from ${suggestion.fromPackage} is not allowed. Use ${suggestion.designSystemWidget} from the Design System instead.',
      ),
    );
  }
}

class _ReplacementSuggestion {
  final String designSystemWidget;
  final String insteadOf;
  final String fromPackage;

  _ReplacementSuggestion({
    required this.designSystemWidget,
    required this.insteadOf,
    required this.fromPackage,
  });
}
