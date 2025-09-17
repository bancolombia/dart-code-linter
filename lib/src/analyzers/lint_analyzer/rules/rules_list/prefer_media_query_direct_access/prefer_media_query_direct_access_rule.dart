import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../../../../../lint_analyzer.dart';
import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class PreferMediaQueryDirectAccessRule extends DartRule {
  static const ruleId = 'prefer-media-query-direct-access';
  static const warningMessage =
      'Prefer direct access to MediaQuery properties for better code readability.';
  static const replaceComment =
      'Consider accessing MediaQuery properties directly.';

  PreferMediaQueryDirectAccessRule([Map<String, Object> config = const {}])
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.style),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor();
    source.unit.visitChildren(visitor);

    return visitor.mediaQueryUsages.map((node) => createIssue(
          rule: this,
          location: nodeLocation(node: node, source: source),
          message: warningMessage,
          replacement: _createReplacement(node),
        ));
  }

  Replacement _createReplacement(MethodInvocation node) {
    final propertyName = node.methodName.name;
    final replacement = '.${propertyName}Of';

    return Replacement(
      comment: replaceComment,
      replacement: replacement,
    );
  }
}
