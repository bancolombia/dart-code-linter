import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import '../../../../../../lint_analyzer.dart';
import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

class UseDesignSystemItemRule extends DartRule {
  static const String ruleId = 'use-design-system-item';

  final Map<String, _ReplacementSuggestion> _configurations;

  UseDesignSystemItemRule([Map<String, Object> config = const {}])
      : _configurations = _ConfigParser.parseConfig(config),
        super(
          id: ruleId,
          severity: readSeverity(config, Severity.warning),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Map<String, Object?> toJson() {
    final json = super.toJson();
    json['configurations'] = _configurations;

    return json;
  }

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor(_configurations, this, source);
    source.unit.visitChildren(visitor);

    return visitor.issues;
  }
}

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

class _ConfigParser {
  static Map<String, _ReplacementSuggestion> parseConfig(
    Map<String, Object> config,
  ) {
    final result = <String, _ReplacementSuggestion>{};

    config.forEach((key, value) {
      if (value is List) {
        for (final item in value) {
          if (item is Map<String, Object>) {
            final insteadOf = item['instead_of'] as String?;
            final fromPackage = item['from_package'] as String?;

            if (insteadOf != null && fromPackage != null) {
              result[insteadOf] = _ReplacementSuggestion(
                designSystemWidget: key,
                insteadOf: insteadOf,
                fromPackage: fromPackage,
              );
            }
          }
        }
      }
    });

    return result;
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
