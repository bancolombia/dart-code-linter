import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/avoid_non_configurable_callbacks_in_init_state/avoid_non_configurable_callbacks_in_init_state_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath =
    'avoid_non_configurable_callbacks_in_init_state/examples/example.dart';

void main() {
  group('AvoidNonConfigurableCallbacksInInitStateRule', () {
    test('initialization', () {
      final rule = AvoidNonConfigurableCallbacksInInitStateRule();

      expect(rule.id, 'avoid-non-configurable-callbacks-in-init-state');
      expect(rule.severity, Severity.warning);
    });

    test(
        'reports the fully hardcoded configurations built in initState '
        '(including two in one initState), and not the '
        'partially-configurable one, the one built off a local variable, or '
        'the one built outside initState', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = AvoidNonConfigurableCallbacksInInitStateRule().check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [20, 151, 156],
      );
    });
  });
}
