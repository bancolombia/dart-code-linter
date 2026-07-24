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
        'reports a default case and a wildcard pattern case in switch statements over sealed types',
        () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues =
          AvoidNonExhaustiveSwitchOnSealedClassesRule().check(unit);

      expect(issues, hasLength(3));
      for (final issue in issues) {
        expect(issue.message, contains('sealed type'));
      }
    });
  });
}
