import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/prefer_static_class/prefer_static_class_rule.dart';
import 'package:test/test.dart';

import '../../../../../helpers/rule_test_helper.dart';

const _incorrectExamplePath =
    'prefer_static_class/examples/incorrect_example.dart';
const _correctExamplePath = 'prefer_static_class/examples/correct_example.dart';
const _correctIgnorePrivateExamplePath =
    'prefer_static_class/examples/correct_ignore_private_example.dart';
const _correctIgnoreNamesExamplePath =
    'prefer_static_class/examples/correct_ignore_names_example.dart';
const _correctIgnoreAnnotationExamplePath =
    'prefer_static_class/examples/correct_ignore_annotation_example.dart';

/// Whether the running analyzer can parse primary constructors
/// (`class Example(final int value) {}`), which landed in analyzer 9.0.0.
///
/// `correct_example.dart` declares one. On analyzer 8.x the parser cannot read
/// it, and error recovery splits the class open: `Example` comes back empty and
/// the members it declares surface as top-level declarations, which
/// `prefer-static-class` then correctly reports. The capability is probed
/// rather than the version compared, so this stays right if the feature is
/// backported or the supported range moves.
bool get _parsesPrimaryConstructors =>
    parseString(
      content: 'class Example(final int value) { void method() {} }',
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    ).unit.declarations.length ==
    1;

void main() {
  group('PreferStaticClassRule', () {
    test('initialization', () async {
      final unit = await RuleTestHelper.resolveFromFile(_incorrectExamplePath);
      final issues = PreferStaticClassRule().check(unit);

      RuleTestHelper.verifyInitialization(
        issues: issues,
        ruleId: 'prefer-static-class',
        severity: Severity.style,
      );
    });

    test('reports issues on incorrect example', () async {
      final unit = await RuleTestHelper.resolveFromFile(_incorrectExamplePath);
      final issues = PreferStaticClassRule().check(unit);

      RuleTestHelper.verifyIssues(
        issues: issues,
        startLines: [1, 2, 3, 4, 6, 7, 8, 9],
        startColumns: [1, 1, 1, 1, 1, 1, 1, 1],
        locationTexts: [
          'void globalFunction() {}',
          'var globalVariable = 42;',
          'final globalFinalVariable = 42;',
          'const globalConstant = 42;',
          'void _privateGlobalFunction() {}',
          'var _privateGlobalVariable = 42;',
          'final _privateGlobalFinalVariable = 42;',
          'const _privateGlobalConstant = 42;',
        ],
        messages: [
          'Prefer declaring static class members instead of global functions, variables and constants.',
          'Prefer declaring static class members instead of global functions, variables and constants.',
          'Prefer declaring static class members instead of global functions, variables and constants.',
          'Prefer declaring static class members instead of global functions, variables and constants.',
          'Prefer declaring static class members instead of global functions, variables and constants.',
          'Prefer declaring static class members instead of global functions, variables and constants.',
          'Prefer declaring static class members instead of global functions, variables and constants.',
          'Prefer declaring static class members instead of global functions, variables and constants.',
        ],
      );
    });

    test('do not reports any issues on correct example', () async {
      final unit = await RuleTestHelper.resolveFromFile(_correctExamplePath);
      final issues = PreferStaticClassRule().check(unit);

      if (_parsesPrimaryConstructors) {
        RuleTestHelper.verifyNoIssues(issues);

        return;
      }

      // Asserted rather than skipped, so this fails loudly the day the guard
      // stops being needed: if the fixture drops its primary constructor, or
      // the supported analyzer range no longer reaches below 9.0.0, this
      // branch starts seeing a clean parse and the guard should be deleted.
      expect(
        issues,
        isNotEmpty,
        reason: 'This analyzer cannot parse the primary constructor in the '
            'fixture, so recovery is expected to lift the members of Example '
            'to the top level, where prefer-static-class reports them.',
      );
    });

    test(
      'do not reports any issues on correct "ignore private" example',
      () async {
        final unit = await RuleTestHelper.resolveFromFile(
          _correctIgnorePrivateExamplePath,
        );
        final issues = PreferStaticClassRule({
          'ignore-private': true,
        }).check(unit);

        RuleTestHelper.verifyNoIssues(issues);
      },
    );

    test(
      'do not reports any issues on correct "ignore names" example',
      () async {
        final unit = await RuleTestHelper.resolveFromFile(
          _correctIgnoreNamesExamplePath,
        );
        final issues = PreferStaticClassRule({
          'ignore-names': [
            '(.*)Provider',
            'use(.*)',
          ],
        }).check(unit);

        RuleTestHelper.verifyNoIssues(issues);
      },
    );

    test(
      'do not reports any issues on correct "ignore annotation" example',
      () async {
        final unit = await RuleTestHelper.resolveFromFile(
          _correctIgnoreAnnotationExamplePath,
        );
        final issues = PreferStaticClassRule({
          'ignore-annotations': [
            'ignoredAnnotation',
          ],
        }).check(unit);

        RuleTestHelper.verifyNoIssues(issues);
      },
    );
  });
}
