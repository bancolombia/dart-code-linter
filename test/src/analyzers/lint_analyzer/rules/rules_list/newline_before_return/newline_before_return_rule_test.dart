import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/issue.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/newline_before_return/newline_before_return_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'newline_before_return/examples/example.dart';
const _beforeFixExamplePath = 'newline_before_return/examples/before_fix.dart';
const _afterFixExamplePath = 'newline_before_return/examples/after_fix.dart';
const _commentsBeforeFixPath =
    'newline_before_return/examples/comments_before_return.before.dart';
const _commentsAfterFixPath =
    'newline_before_return/examples/comments_before_return.after.dart';
const _alreadyBlankLineBeforePath =
    'newline_before_return/examples/already_blank_line.before.dart';
const _alreadyBlankLineAfterPath =
    'newline_before_return/examples/already_blank_line.after.dart';
const _tabIndentationBeforePath =
    'newline_before_return/examples/tab_indentation.before.dart';
const _tabIndentationAfterPath =
    'newline_before_return/examples/tab_indentation.after.dart';
const _bareReturnBeforePath =
    'newline_before_return/examples/bare_return.before.dart';
const _bareReturnAfterPath =
    'newline_before_return/examples/bare_return.after.dart';

void main() {
  group('NewlineBeforeReturnRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = NewlineBeforeReturnRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'newline-before-return',
        severity: Severity.style,
      );
    });

    test('reports about found issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = NewlineBeforeReturnRule().check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [11, 57, 70],
        startColumns: [1, 1, 1],
        locationTexts: [
          '    /* multi line\n      comment */\n    return a + 1;',
          '    // simple comment\n    return a + 2;',
          '    return a + 2;',
        ],
        messages: [
          'Missing blank line before return.',
          'Missing blank line before return.',
          'Missing blank line before return.',
        ],
      );
    });

    test('provides replacement suggestions', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = NewlineBeforeReturnRule().check(unit);

      expect(issues, isNotEmpty);

      for (final issue in issues) {
        expect(issue.suggestions, isNotNull);
        expect(issue.suggestions, isNotEmpty);
        expect(
          issue.suggestions!.first.comment,
          equals('Insert blank line before return.'),
        );
        expect(
          issue.suggestions!.first.replacement,
          startsWith('\n'),
        );
      }
    });

    test('applies fix suggestions to fixture input', () async {
      await _verifyFixtureFix(
        beforePath: _beforeFixExamplePath,
        afterPath: _afterFixExamplePath,
      );
    });

    test('applies fix when comment is before return', () async {
      await _verifyFixtureFix(
        beforePath: _commentsBeforeFixPath,
        afterPath: _commentsAfterFixPath,
      );
    });

    test('does not report issue when blank line already exists', () async {
      final before =
          await RuleTestHelper.resolveFromFile(_alreadyBlankLineBeforePath);
      final expected =
          await RuleTestHelper.resolveFromFile(_alreadyBlankLineAfterPath);
      final issues = NewlineBeforeReturnRule().check(before).toList();

      expect(issues, isEmpty);

      final transformed = _applyFirstSuggestions(before.content, issues);
      expect(transformed, equals(expected.content));
    });

    test('preserves tab indentation when applying fix', () async {
      await _verifyFixtureFix(
        beforePath: _tabIndentationBeforePath,
        afterPath: _tabIndentationAfterPath,
      );
    });

    test('applies fix for bare return with no value', () async {
      await _verifyFixtureFix(
        beforePath: _bareReturnBeforePath,
        afterPath: _bareReturnAfterPath,
      );
    });

    test('fix is idempotent across multiple issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = NewlineBeforeReturnRule().check(unit).toList();
      expect(issues, hasLength(3));

      final fixed = _applyFirstSuggestions(unit.content, issues);
      final fixedUnit = await RuleTestHelper.createAndResolveFromFile(
        content: fixed,
        filePath: 'newline_before_return/examples/_idempotency_temp.dart',
      );
      final issuesAfterFix =
          NewlineBeforeReturnRule().check(fixedUnit).toList();
      expect(issuesAfterFix, isEmpty);
    });

    test('does not report when return is first statement in block', () async {
      final unit = await RuleTestHelper.createAndResolveFromFile(
        content: 'int f(int a) {\n  return a + 1;\n}\n',
        filePath: 'newline_before_return/examples/_first_statement_temp.dart',
      );
      final issues = NewlineBeforeReturnRule().check(unit).toList();
      expect(issues, isEmpty);
    });
  });
}

Future<void> _verifyFixtureFix({
  required String beforePath,
  required String afterPath,
}) async {
  final before = await RuleTestHelper.resolveFromFile(beforePath);
  final expected = await RuleTestHelper.resolveFromFile(afterPath);
  final issues = NewlineBeforeReturnRule().check(before).toList();

  expect(issues, isNotEmpty);

  final transformed = _applyFirstSuggestions(before.content, issues);
  expect(transformed, equals(expected.content));
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
