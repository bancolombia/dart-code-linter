import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/prefer_dot_shorthands/prefer_dot_shorthands_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'prefer_dot_shorthands/examples/example.dart';

void main() {
  group('PreferDotShorthandsRule', () {
    test('initialization', () {
      final rule = PreferDotShorthandsRule();

      expect(rule.id, 'prefer-dot-shorthands');
      expect(rule.severity, Severity.style);
    });

    test(
        'reports enum/static member access, static method calls and named constructor calls whose type is inferable from context, and nothing else',
        () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferDotShorthandsRule().check(unit);

      expect(issues, hasLength(5));

      final replacements = issues
          .map((issue) => issue.suggestions!.single.replacement)
          .toSet();

      expect(
        replacements,
        {
          '.error',
          '.warning',
          '.info',
          '.origin()',
          '.zero()',
        },
      );
    });
  });
}
