import 'dart:convert';
import 'dart:io';

import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/prefer_dot_shorthands/prefer_dot_shorthands_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _examplePath = 'prefer_dot_shorthands/examples/example.dart';
const _preDotShorthandsExamplePath =
    'prefer_dot_shorthands/examples/example_pre_dot_shorthands.dart';
const _fixedExamplePath =
    'test/src/analyzers/lint_analyzer/rules/rules_list/prefer_dot_shorthands/examples/example_fixed.dart';

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

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [21, 26, 31, 37, 42],
        replacements: [
          '.error',
          '.warning',
          '.info',
          '.origin()',
          '.zero()',
        ],
      );
    });

    test(
        'is silent on a file whose language version predates dot shorthands',
        () async {
      final unit =
          await RuleTestHelper.resolveFromFile(_preDotShorthandsExamplePath);
      final issues = PreferDotShorthandsRule().check(unit);

      RuleTestHelper.verifyNoIssues(issues);
    });

    test(
        'applying every suggested replacement keeps the example compiling '
        '(guards against fixes whose context type is inferred from the '
        'argument itself)', () async {
      final unit = await RuleTestHelper.resolveFromFile(_examplePath);
      final issues = PreferDotShorthandsRule().check(unit).toList()
        ..sort(
          (a, b) => b.location.start.offset.compareTo(a.location.start.offset),
        );

      var fixedContent = unit.content;
      for (final issue in issues) {
        fixedContent = fixedContent.replaceRange(
          issue.location.start.offset,
          issue.location.end.offset,
          issue.suggestions!.single.replacement,
        );
      }

      // The fixture opts in to Dart 3.10 via its own `// @dart` marker
      // (this package's language version is lower), so the rewritten
      // content stays valid as-is.
      final fixedFile = File(_fixedExamplePath)
        ..writeAsStringSync(fixedContent);
      addTearDown(() {
        if (fixedFile.existsSync()) {
          fixedFile.deleteSync();
        }
      });

      final result = await Process.run(
        Platform.resolvedExecutable,
        ['analyze', '--format=machine', fixedFile.path],
      );
      final compileErrors =
          LineSplitter.split('${result.stdout}${result.stderr}')
              .where((line) => line.startsWith('ERROR|'))
              .toList();

      expect(compileErrors, isEmpty);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
