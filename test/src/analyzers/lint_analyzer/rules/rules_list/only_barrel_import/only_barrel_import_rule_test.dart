import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/only_barrel_import/only_barrel_import_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'only_barrel_import/examples';
const _withNoImport = '$_examplePath/example_with_no_imports.dart';
const _withWrongCoreImport =
    '$_examplePath/example_with_wrong_core_import.dart';
const _withRightCoreImport =
    '$_examplePath/example_with_right_core_import.dart';

void main() {
  group('OnlyBarrelImportRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withNoImport);
      final issues = OnlyBarrelImportRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'only-barrel-import',
        severity: Severity.error,
      );
    });

    test('reports no issues', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withNoImport);
      final issues = OnlyBarrelImportRule().check(unit);

      RuleTestHelper.verifyNoIssues(issues);
    });

    test('reports about found issue about wrong import', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withWrongCoreImport);
      final issues = OnlyBarrelImportRule({
        'barrels': ['core'],
      }).check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [1],
        startColumns: [1],
        messages: [
          'You should only use barrel imports for external modules. Please use the following format: `package:package_name/package_name.dart`.',
        ],
        locationTexts: ["import 'package:core/some_other_file.dart';"],
      );
    });

    test('reports no issues for correct import', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withRightCoreImport);
      final issues = OnlyBarrelImportRule({
        'barrels': ['core'],
      }).check(unit);

      RuleTestHelper.verifyNoIssues(issues);
    });

    test('reports no issues for empty file', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withNoImport);
      final issues = OnlyBarrelImportRule({
        'barrels': ['core'],
      }).check(unit);

      RuleTestHelper.verifyNoIssues(issues);
    });

    test('reports no issues for file with non matching barrel', () async {
      final unit = await RuleTestHelper.resolveFromFile(_withNoImport);
      final issues = OnlyBarrelImportRule({
        'barrels': ['some_other_barrel'],
      }).check(unit);

      RuleTestHelper.verifyNoIssues(issues);
    });
  });
}
