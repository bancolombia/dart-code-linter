import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../../../../../lint_analyzer.dart';
import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../models/flutter_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class PreferMediaQueryDirectAccessRule extends FlutterRule {
  static const ruleId = 'prefer-media-query-direct-access';
  static const warningMessage = '''
      Prefer using this function over getting the attribute directly from the MediaQueryData returned from of, 
      because using this function will only rebuild the context when this specific attribute changes, 
      not when any attribute changes.''';
  static const replaceComment =
      'Consider accessing MediaQuery properties directly.';

  PreferMediaQueryDirectAccessRule([Map<String, Object> config = const {}])
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.performance),
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
          replacements: _createReplacement(node),
        ));
  }

  List<Replacement> _createReplacement(PropertyAccess node) {
    final propertyName = node.propertyName.name;
    final target = node.target as MethodInvocation;
    final context = target.argumentList.arguments.first;

    final replacement = 'MediaQuery.${propertyName}Of($context)';

    return [
      Replacement(
        comment: replaceComment,
        replacement: replacement,
      ),
    ];
  }
}
