// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';

import '../../../../../utils/dart_types_utils.dart';
import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/replacement.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class PreferFirstOrNullRule extends DartRule {
  static const ruleId = 'prefer-first-or-null';
  static const warningMessage =
      'Use firstOrNull instead of accessing the element at zero index or using first.';
  static const replaceComment = "Replace with 'firstOrNull'.";

  PreferFirstOrNullRule([Map<String, Object> config = const {}])
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

    return visitor.expressions
        .map((expression) => createIssue(
              rule: this,
              location: nodeLocation(node: expression, source: source),
              message: warningMessage,
              replacements: _createReplacement(expression),
            ))
        .toList(growable: false);
  }

  List<Replacement> _createReplacement(Expression expression) {
    String replacement;

    if (expression is MethodInvocation) {
      replacement = expression.isCascaded
          ? '..firstOrNull'
          : '${expression.target ?? ''}.firstOrNull';
    } else if (expression is IndexExpression) {
      replacement = expression.isCascaded
          ? '..firstOrNull'
          : '${expression.target ?? ''}.firstOrNull';
    } else if (expression is PrefixedIdentifier) {
      replacement = '${expression.prefix.token.lexeme}.firstOrNull';
    } else {
      replacement = '.firstOrNull';
    }

    return [
      Replacement(
        comment: replaceComment,
        replacement: replacement,
      ),
    ];
  }
}
