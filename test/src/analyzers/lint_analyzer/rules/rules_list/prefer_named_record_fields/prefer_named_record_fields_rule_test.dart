import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/prefer_named_record_fields/prefer_named_record_fields_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'prefer_named_record_fields/examples/example.dart';

void main() {
  group('PreferNamedRecordFieldsRule', () {
    test('initialization', () {
      final rule = PreferNamedRecordFieldsRule();

      expect(rule.id, 'prefer-named-record-fields');
      expect(rule.severity, Severity.style);
    });

    test('reports about record types with only positional fields', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferNamedRecordFieldsRule().check(unit);

      expect(issues, isNotEmpty);
      expect(issues.first.message, contains('Prefer named record fields'));
    });
  });
}
