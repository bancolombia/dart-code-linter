import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/require_trailing_commas/require_trailing_commas_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

// ignore_for_file: avoid_escaping_inner_quotes

const _correctExamplePath =
    'require_trailing_commas/examples/correct_example.dart';
const _incorrectExamplePath =
    'require_trailing_commas/examples/incorrect_example.dart';

void main() {
  group('RequireTrailingCommas', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_correctExamplePath);
      final issues = RequireTrailingCommasRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'prefer-trailing-comma',
        severity: Severity.style,
      );
    });

    test('with default config reports about found issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_incorrectExamplePath);
      final issues = RequireTrailingCommasRule().check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [3, 9, 13, 18, 24, 28, 49, 58, 64, 70, 74, 84, 94],
        startColumns: [50, 7, 5, 52, 9, 8, 59, 3, 3, 3, 50, 29, 23],
        locationTexts: [
          'String thirdArgument',
          "'and another string for length exceed'",
          'String arg3',
          'String thirdArgument',
          "'and another string for length exceed'",
          "'some other string'",
          'this.forthField',
          "'and another string for length exceed'",
          "'and another string for length exceed'",
          "'and another string for length exceed': 'and another string for length exceed'",
          "String forthArgument",
          "String forthArgument",
          'FirstClass(\n'
              '  3.14159265359,\n'
              '  3.14159265359,\n'
              '  3.14159265359,\n'
              '  3.14159265359,\n'
              ')',
        ],
        messages: [
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
        ],
        replacementComments: [
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
        ],
        replacements: [
          'String thirdArgument,',
          "'and another string for length exceed',",
          'String arg3,',
          'String thirdArgument,',
          "'and another string for length exceed',",
          "'some other string',",
          'this.forthField,',
          "'and another string for length exceed',",
          "'and another string for length exceed',",
          "'and another string for length exceed': 'and another string for length exceed',",
          "String forthArgument,",
          "String forthArgument,",
          'FirstClass(\n'
              '  3.14159265359,\n'
              '  3.14159265359,\n'
              '  3.14159265359,\n'
              '  3.14159265359,\n'
              '),',
        ],
      );
    });

    test('with default config reports no issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_correctExamplePath);
      final issues = RequireTrailingCommasRule().check(unit);

      RuleTestHelper.verifyNoIssues(issues);
    });

    test('with custom config reports about found issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_incorrectExamplePath);
      final config = {'min-parameters': 1};

      final issues = RequireTrailingCommasRule(config).check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [3, 9, 13, 18, 24, 28, 49, 58, 64, 70, 74, 84],
        startColumns: [50, 7, 5, 52, 9, 8, 59, 3, 3, 3, 50, 29],
        locationTexts: [
          'String thirdArgument',
          "'and another string for length exceed'",
          'String arg3',
          'String thirdArgument',
          "'and another string for length exceed'",
          "'some other string'",
          'this.forthField',
          "'and another string for length exceed'",
          "'and another string for length exceed'",
          "'and another string for length exceed': 'and another string for length exceed'",
          "String forthArgument",
          "String forthArgument",
        ],
        messages: [
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
          'Require trailing comma.',
        ],
        replacementComments: [
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
          'Add trailing comma.',
        ],
        replacements: [
          'String thirdArgument,',
          "'and another string for length exceed',",
          'String arg3,',
          'String thirdArgument,',
          "'and another string for length exceed',",
          "'some other string',",
          'this.forthField,',
          "'and another string for length exceed',",
          "'and another string for length exceed',",
          "'and another string for length exceed': 'and another string for length exceed',",
          "String forthArgument,",
          "String forthArgument,",
        ],
      );
    });
  });
}
