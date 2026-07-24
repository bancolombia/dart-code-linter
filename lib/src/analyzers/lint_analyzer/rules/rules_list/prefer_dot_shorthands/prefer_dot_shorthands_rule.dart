// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../../../../../utils/ast_compat.dart';
import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/replacement.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class PreferDotShorthandsRule extends DartRule {
  static const ruleId = 'prefer-dot-shorthands';
  static const warningMessage =
      'Prefer a dot shorthand over repeating the type name when it is already inferable from the surrounding context.';
  static const replaceComment = 'Consider using a dot shorthand.';

  PreferDotShorthandsRule([Map<String, Object> config = const {}])
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

    return visitor.candidates
        .map((candidate) => createIssue(
              rule: this,
              location: nodeLocation(node: candidate.node, source: source),
              message: warningMessage,
              replacements: [
                Replacement(
                  comment: replaceComment,
                  replacement: candidate.replacement,
                ),
              ],
            ))
        .toList(growable: false);
  }
}
