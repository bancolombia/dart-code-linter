import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/issue.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/avoid_duplicate_exports/avoid_duplicate_exports_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'avoid_duplicate_exports/examples/example.dart';
const _beforeFixPath = 'avoid_duplicate_exports/examples/fix.before.dart';
const _afterFixPath = 'avoid_duplicate_exports/examples/fix.after.dart';

void main() {
  group('AvoidDuplicateExportsRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = AvoidDuplicateExportsRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'avoid-duplicate-exports',
        severity: Severity.warning,
      );
    });

    test('reports about all found issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);

      final issues = AvoidDuplicateExportsRule().check(unit);

      // The location spans the whole line so the fix can delete it cleanly,
      // hence column 1 and a location text that includes the trailing comment.
      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [6],
        startColumns: [1],
        locationTexts: [
          "export 'package:intl/good_folder/something.dart'; // LINT\n",
        ],
        messages: [
          'Avoid declaring duplicate exports.',
        ],
      );
    });

    test('provides replacement suggestions', () async {
      final unit = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final issues = AvoidDuplicateExportsRule().check(unit);

      expect(issues, isNotEmpty);

      for (final issue in issues) {
        expect(issue.suggestions, isNotNull);
        expect(issue.suggestions, isNotEmpty);
        expect(
          issue.suggestions!.first.comment,
          equals('Delete the duplicate export directive.'),
        );
        expect(issue.suggestions!.first.replacement, isEmpty);
      }
    });

    test('applies fix suggestions to fixture input', () async {
      final before = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final expected = await RuleTestHelper.resolveFromFile(_afterFixPath);
      final issues = AvoidDuplicateExportsRule().check(before).toList();

      expect(issues, isNotEmpty);

      final transformed = _applyFirstSuggestions(before.content, issues);
      expect(transformed, equals(expected.content));
    });

    test('deletes a duplicate on the last line without a trailing newline',
        () async {
      final unit = await RuleTestHelper.createAndResolveFromFile(
        content: "export 'package:a/a.dart';\n"
            "export 'package:a/a.dart';",
        filePath: 'avoid_duplicate_exports/examples/_no_newline_temp.dart',
      );
      final issues = AvoidDuplicateExportsRule().check(unit).toList();

      final fixed = _applyFirstSuggestions(unit.content, issues);

      expect(fixed, equals("export 'package:a/a.dart';\n"));
    });

    test('deletes every duplicate when a URI is exported three times',
        () async {
      final unit = await RuleTestHelper.createAndResolveFromFile(
        content: "export 'package:a/a.dart';\n"
            "export 'package:a/a.dart';\n"
            "export 'package:a/a.dart';\n",
        filePath: 'avoid_duplicate_exports/examples/_triple_temp.dart',
      );
      final issues = AvoidDuplicateExportsRule().check(unit).toList();

      expect(issues, hasLength(2));

      final fixed = _applyFirstSuggestions(unit.content, issues);

      expect(fixed, equals("export 'package:a/a.dart';\n"));
    });

    test('removes a trailing line comment together with the duplicate line',
        () async {
      final unit = await RuleTestHelper.createAndResolveFromFile(
        content: "export 'package:a/a.dart';\n"
            "export 'package:a/a.dart'; // dup note\n"
            "export 'package:b/b.dart';\n",
        filePath:
            'avoid_duplicate_exports/examples/_trailing_comment_temp.dart',
      );
      final issues = AvoidDuplicateExportsRule().check(unit).toList();

      final fixed = _applyFirstSuggestions(unit.content, issues);

      expect(
        fixed,
        equals("export 'package:a/a.dart';\n"
            "export 'package:b/b.dart';\n"),
      );
    });

    test(
        'only removes the directive when the line tail holds a block comment '
        '(keeps the output valid)', () async {
      // Deleting the whole line here would split the block comment, so only
      // the directive is removed.
      final unit = await RuleTestHelper.createAndResolveFromFile(
        content: "export 'package:a/a.dart';\n"
            "export 'package:a/a.dart'; /* multi\n"
            "line */ export 'package:b/b.dart';\n",
        filePath: 'avoid_duplicate_exports/examples/_block_comment_temp.dart',
      );
      final issues = AvoidDuplicateExportsRule().check(unit).toList();

      final fixed = _applyFirstSuggestions(unit.content, issues);

      expect(
        fixed,
        equals("export 'package:a/a.dart';\n"
            ' /* multi\n'
            "line */ export 'package:b/b.dart';\n"),
      );
      // The surviving exports and the comment are intact, so it still parses.
      final fixedUnit = await RuleTestHelper.createAndResolveFromFile(
        content: fixed,
        filePath: 'avoid_duplicate_exports/examples/_block_comment_fixed.dart',
      );
      expect(AvoidDuplicateExportsRule().check(fixedUnit), isEmpty);
    });

    test('fix is idempotent (no issues remain after applying)', () async {
      final before = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final issues = AvoidDuplicateExportsRule().check(before).toList();

      final fixed = _applyFirstSuggestions(before.content, issues);
      final fixedUnit = await RuleTestHelper.createAndResolveFromFile(
        content: fixed,
        filePath: 'avoid_duplicate_exports/examples/_idempotency_temp.dart',
      );
      final issuesAfterFix =
          AvoidDuplicateExportsRule().check(fixedUnit).toList();

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
