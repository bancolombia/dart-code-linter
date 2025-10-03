import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/use_design_system/use_design_system_item_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'use_design_system_item/examples';
const _withSingleClass = '$_examplePath/example.dart';
const _withSuppression = '$_examplePath/example_with_suppression.dart';

class Scaffold {}

void main() {
  group('UseDesignSystemRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withSingleClass);
      final issues = UseDesignSystemItemRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'use-design-system-item',
        severity: Severity.style,
      );
    });

    test('reports no issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withSingleClass);
      final issues = UseDesignSystemItemRule().check(unit);

      RuleTestHelper.verifyNoIssues(issues);
    });

    test('reports about suppression instead of basescreen', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withSuppression);
      final rule = UseDesignSystemItemRule({
        'BaseScreen': [
          {'instead_of': 'Suppression', 'from_package': 'dart_code_linter'},
        ],
      });
      final issues = rule.check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [8],
        startColumns: [12],
        messages: [
          'Suppression from dart_code_linter is not allowed. Use BaseScreen from the Design System instead.',
        ],
        locationTexts: ['Suppression()'],
      );
    });

    test('does not report about suppression instead of basescreen', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withSuppression);
      final rule = UseDesignSystemItemRule({
        'BaseScreen': [
          {'instead_of': 'NotSuppression', 'from_package': 'dart_code_linter'},
        ],
      });
      final issues = rule.check(unit);

      RuleTestHelper.verifyNoIssues(issues);
    });
  });
}
