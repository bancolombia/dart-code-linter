import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/issue.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/no_blank_line_before_single_return/no_blank_line_before_single_return_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'no_blank_line_before_single_return/examples/example.dart';
const _beforeFixPath =
    'no_blank_line_before_single_return/examples/fix.before.dart';
const _afterFixPath =
    'no_blank_line_before_single_return/examples/fix.after.dart';

void main() {
  group('NoBlankLineBeforeSingleReturnRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = NoBlankLineBeforeSingleReturnRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: NoBlankLineBeforeSingleReturnRule.ruleId,
        severity: Severity.style,
      );
    });

    test('reports about found issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = NoBlankLineBeforeSingleReturnRule().check(unit);

      // The location spans the blank line(s) through the return so the fix can
      // replace that region, so it starts at the line following the block's
      // opening brace, at column 1.
      final startLines = <int>[78, 83, 89, 96, 104, 110, 117];

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: startLines,
        startColumns: List.generate(startLines.length, (index) => 1),
        messages: List.generate(startLines.length,
            (index) => NoBlankLineBeforeSingleReturnRule.warning),
      );
    });

    test('provides replacement suggestions', () async {
      final unit = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final issues = NoBlankLineBeforeSingleReturnRule().check(unit);

      expect(issues, isNotEmpty);

      for (final issue in issues) {
        expect(issue.suggestions, isNotNull);
        expect(issue.suggestions, isNotEmpty);
        expect(
          issue.suggestions!.first.comment,
          equals('Remove blank line before return.'),
        );
      }
    });

    test('applies fix suggestions to fixture input', () async {
      final before = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final expected = await RuleTestHelper.resolveFromFile(_afterFixPath);
      final issues =
          NoBlankLineBeforeSingleReturnRule().check(before).toList();

      expect(issues, isNotEmpty);

      final transformed = _applyFirstSuggestions(before.content, issues);
      expect(transformed, equals(expected.content));
    });

    test('fix is idempotent (no issues remain after applying)', () async {
      final before = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final issues =
          NoBlankLineBeforeSingleReturnRule().check(before).toList();

      final fixed = _applyFirstSuggestions(before.content, issues);
      final fixedUnit = await RuleTestHelper.createAndResolveFromFile(
        content: fixed,
        filePath:
            'no_blank_line_before_single_return/examples/_idempotency_temp.dart',
      );
      final issuesAfterFix =
          NoBlankLineBeforeSingleReturnRule().check(fixedUnit).toList();

      expect(issuesAfterFix, isEmpty);
    });
  });
}

String _applyFirstSuggestions(String content, List<Issue> issues) {
  final sortedIssues = issues.toList()
    ..sort(
      (a, b) => b.location.start.offset.compareTo(a.location.start.offset),
    );

  var fixed = content;
  for (final issue in sortedIssues) {
    final suggestion = issue.suggestions?.first;
    if (suggestion == null) {
      continue;
    }

    fixed = fixed.replaceRange(
      issue.location.start.offset,
      issue.location.end.offset,
      suggestion.replacement,
    );
  }

  return fixed;
}
