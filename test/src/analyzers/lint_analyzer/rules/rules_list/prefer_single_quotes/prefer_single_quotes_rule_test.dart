import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/prefer_single_quotes/prefer_single_quotes_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'prefer_single_quotes/examples/example.dart';

void main() {
  group(
    'PreferSingleQuotesRule',
    () {
      test('initialization', () async {
        final unit = await RuleTestHelper.resolveFromFile(_examplePath);
        final issues = PreferSingleQuotesRule().check(unit);

        RuleTestHelper.verifyInitialization(
          issues: issues,
          ruleId: PreferSingleQuotesRule.ruleId,
          severity: Severity.style,
        );
      });

      test('reports about found issues', () async {
        final unit = await RuleTestHelper.resolveFromFile(_examplePath);
        final issues = PreferSingleQuotesRule().check(unit);

        RuleTestHelper.verifyIssues(
          issues: issues,
          startLines: [
            6,
            9,
            12,
          ],
          startColumns: [
            25,
            25,
            25,
          ],
          messages: [
            'Use single quotation marks instead of double quotations.',
            'Use single quotation marks instead of double quotations.',
            'Use single quotation marks instead of double quotations.',
          ],
          replacementComments: [
            "Replace with ''.",
            "Replace with ''.",
            "Replace with ''.",
          ],
          replacements: [
            "'some value'",
            '\'some value "another text"\'',
            "'  multi line text\n"
                "  '",
          ],
          locationTexts: [
            '"some value"',
            r'"some value \"another text\""',
            '"""\n'
                '  multi line text\n'
                '  """',
          ],
        );
      });
    },
  );
}
