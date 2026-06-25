import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/issue.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/prefer_enums_by_name/prefer_enums_by_name_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'prefer_enums_by_name/examples/example.dart';
const _beforeFixPath = 'prefer_enums_by_name/examples/fix.before.dart';
const _afterFixPath = 'prefer_enums_by_name/examples/fix.after.dart';

void main() {
  group('PreferEnumsByNameRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferEnumsByNameRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'prefer-enums-by-name',
        severity: Severity.style,
      );
    });

    test('reports about found issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferEnumsByNameRule().check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [6, 8],
        startColumns: [3, 3],
        locationTexts: [
          "SomeEnums.values.firstWhere((element) => element.name == 'first')",
          'SomeEnums.values\n'
              "      .firstWhere((element) => element.name == 'second', orElse: () => null)",
        ],
        messages: [
          'Prefer using values.byName',
          'Prefer using values.byName',
        ],
      );
    });

    test('offers a fix only for convertible invocations', () async {
      final unit = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final issues = PreferEnumsByNameRule().check(unit).toList();

      // Every `Enum.values.firstWhere(...)` is reported, but only the three
      // convertible shapes carry a replacement suggestion.
      final withFix = issues.where((i) => i.suggestions?.isNotEmpty ?? false);
      final withoutFix = issues.where((i) => i.suggestions?.isEmpty ?? true);

      expect(withFix, hasLength(3));
      expect(withoutFix, hasLength(4));

      for (final issue in withFix) {
        expect(
          issue.suggestions!.first.comment,
          equals('Convert to values.byName().'),
        );
      }
    });

    test('applies fix suggestions to fixture input', () async {
      final before = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final expected = await RuleTestHelper.resolveFromFile(_afterFixPath);
      final issues = PreferEnumsByNameRule().check(before).toList();

      final transformed = _applyFirstSuggestions(before.content, issues);
      expect(transformed, equals(expected.content));
    });

    test('fix is idempotent (no convertible issues remain)', () async {
      final before = await RuleTestHelper.resolveFromFile(_beforeFixPath);
      final issues = PreferEnumsByNameRule().check(before).toList();

      final fixed = _applyFirstSuggestions(before.content, issues);
      final fixedUnit = await RuleTestHelper.createAndResolveFromFile(
        content: fixed,
        filePath: 'prefer_enums_by_name/examples/_idempotency_temp.dart',
      );
      final remaining = PreferEnumsByNameRule()
          .check(fixedUnit)
          .where((i) => i.suggestions?.isNotEmpty ?? false);

      expect(remaining, isEmpty);
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
    final suggestions = issue.suggestions;
    if (suggestions == null || suggestions.isEmpty) {
      continue;
    }

    fixed = fixed.replaceRange(
      issue.location.start.offset,
      issue.location.end.offset,
      suggestions.first.replacement,
    );
  }

  return fixed;
}
