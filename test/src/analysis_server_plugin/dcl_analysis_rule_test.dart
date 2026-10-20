import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_code_linter/src/analysis_server_plugin/dcl_analysis_rule.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/internal_resolved_unit_result.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/issue.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/models/rule.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/models/rule_type.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_factory.dart';
import 'package:test/test.dart';

const _rule = 'no-magic-number';
const _path = '/project/lib/a.dart';

void main() {
  group('unsuppressedIssues drops what an ignore comment suppresses', () {
    /// The issues [rule] reports in [content] that are left to report.
    List<String> remaining(String content, {Rule? rule}) {
      final unit = parseString(content: content, path: _path).unit;
      final issues = unsuppressedIssues(
        rule ?? getRulesById({_rule: {}}).single,
        InternalResolvedUnitResult(_path, content, unit, unit.lineInfo),
      );

      return [
        for (final issue in issues)
          content.substring(
            issue.location.start.offset,
            issue.location.end.offset,
          ),
      ];
    }

    test('on its line or the next, as on the command line', () {
      // The analysis server cannot do it: it reads only letters, digits and
      // underscores as a diagnostic name, and rule ids have hyphens.
      const content = '''
// ignore: no-magic-number
int a() => 1001;
int b() => 1002; // ignore: dart_code_linter/no-magic-number
// ignore: dart_code_linter/no-magic-number
int c() => 1003;
// ignore: other_plugin/no-magic-number
int d() => 1004;
// ignore: avoid-dynamic
int e() => 1005;
int f() => 1006;
''';

      expect(remaining(content), ['1004', '1005', '1006']);
    });

    for (final comment in [
      '// ignore_for_file: no-magic-number',
      '// ignore_for_file: dart_code_linter/no-magic-number',
      '// ignore_for_file: type=lint',
    ]) {
      test('in the whole file, without running the rule: $comment', () {
        final rule = _CountingRule();

        expect(remaining('$comment\nint a() => 1001;\n', rule: rule), isEmpty);
        expect(rule.runs, 0);
      });
    }

    test('nothing when no comment names the rule', () {
      final rule = _CountingRule();

      expect(
        remaining('// ignore_for_file: avoid-dynamic\nint a() => 1001;\n'),
        ['1001'],
      );
      expect(
        remaining('// ignore_for_file: avoid-dynamic\n', rule: rule),
        isEmpty,
      );
      expect(rule.runs, 1);
    });
  });
}

/// A [_rule] that reports nothing and counts how often it runs.
class _CountingRule extends Rule {
  int runs = 0;

  _CountingRule()
      : super(
          id: _rule,
          type: RuleType.dart,
          severity: Severity.warning,
          excludes: const [],
          includes: const [],
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    runs++;

    return const [];
  }
}
