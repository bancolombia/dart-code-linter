// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';

import '../../../../../utils/ast_compat.dart';
import '../../../../../utils/flutter_types_utils.dart';
import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/severity.dart';
import '../../models/flutter_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class AvoidNonConfigurableCallbacksInInitStateRule extends FlutterRule {
  static const ruleId = 'avoid-non-configurable-callbacks-in-init-state';
  static const warningMessage =
      "This configures a widget-supplied object with a callback object whose callbacks never reference the widget's own fields. Callers of this widget have no way to customize this behavior. Consider exposing these callbacks as constructor parameters.";

  AvoidNonConfigurableCallbacksInInitStateRule([
    Map<String, Object> config = const {},
  ]) : super(
          id: ruleId,
          severity: readSeverity(config, Severity.warning),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor();
    source.unit.visitChildren(visitor);

    return visitor.hardcodedConfigurations
        .map((configuration) => createIssue(
              rule: this,
              location: nodeLocation(node: configuration, source: source),
              message: warningMessage,
            ))
        .toList(growable: false);
  }
}
