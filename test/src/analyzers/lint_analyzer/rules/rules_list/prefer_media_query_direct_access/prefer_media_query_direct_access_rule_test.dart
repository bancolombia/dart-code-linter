import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/prefer_media_query_direct_access/prefer_media_query_direct_access_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'prefer_media_query_direct_access/examples/example.dart';

void main() {
  group('PreferMediaQueryDirectAccessRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferMediaQueryDirectAccessRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'prefer-media-query-direct-access',
        severity: Severity.style,
      );
    });

    test('reports about found issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferMediaQueryDirectAccessRule().check(unit);

      // Verify that we found the expected number of MediaQuery.of(context).property issues
      expect(issues.length, greaterThan(20)); // Should find many issues

      for (final issue in issues) {
        expect(
          issue.message,
          equals(
            'Prefer direct access to MediaQuery properties for better code readability.',
          ),
        );
        expect(issue.ruleId, equals('prefer-media-query-direct-access'));
      }
    });

    test('reports correct message', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferMediaQueryDirectAccessRule().check(unit);

      expect(issues.isNotEmpty, isTrue);
      expect(
        issues.first.message,
        equals(
          'Prefer direct access to MediaQuery properties for better code readability.',
        ),
      );
    });

    test('provides replacement suggestions', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferMediaQueryDirectAccessRule().check(unit);

      expect(issues.isNotEmpty, isTrue);

      // Check that suggestions are provided
      for (final issue in issues) {
        expect(issue.suggestions, isNotNull);
        expect(
          issue.suggestions!.first.comment,
          equals('Consider accessing MediaQuery properties directly.'),
        );
        expect(issue.suggestions!.first.replacement, contains('Of'));
      }
    });

    test('accepts custom configuration', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final rule = PreferMediaQueryDirectAccessRule({
        'severity': 'warning',
      });
      final issues = rule.check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'prefer-media-query-direct-access',
        severity: Severity.warning,
      );
    });
  });
}
