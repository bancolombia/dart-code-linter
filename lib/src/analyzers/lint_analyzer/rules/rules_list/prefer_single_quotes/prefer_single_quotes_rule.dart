// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/replacement.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class PreferSingleQuotesRule extends DartRule {
  static const ruleId = 'prefer-single-quotes';
  static const _warningMessage =
      'Use single quotation marks instead of double quotations.';
  static const _replaceComment = "Replace with ''.";

  PreferSingleQuotesRule([Map<String, Object> config = const {}])
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
              message: _warningMessage,
              replacements: _createReplacement(expression),
            ))
        .toList(growable: false);
  }

  List<Replacement> _createReplacement(Expression expression) {
    if (expression is StringLiteral) {
      final originalString = expression.stringValue ?? '';
      final singleQuotedString = "'$originalString'";

      return [
        Replacement(
          comment: _replaceComment,
          replacement: singleQuotedString,
        ),
      ];
    }

    return [
      Replacement(
        comment: _replaceComment,
        replacement: expression.toSource(),
      ),
    ];
  }
}
