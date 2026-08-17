import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/avoid_non_exhaustive_switch_on_sealed_classes/avoid_non_exhaustive_switch_on_sealed_classes_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath =
    'avoid_non_exhaustive_switch_on_sealed_classes/examples/example.dart';

void main() {
  group('AvoidNonExhaustiveSwitchOnSealedClassesRule', () {
    test('initialization', () {
      final rule = AvoidNonExhaustiveSwitchOnSealedClassesRule();

      expect(rule.id, 'avoid-non-exhaustive-switch-on-sealed-classes');
      expect(rule.severity, Severity.style);
    });

    test(
        'reports a default case and unguarded wildcard cases in switches over '
        'sealed types, but not guarded wildcards or non-sealed switches',
        () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues =
          AvoidNonExhaustiveSwitchOnSealedClassesRule().check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [13, 22, 29],
      );
    });
  });
}
