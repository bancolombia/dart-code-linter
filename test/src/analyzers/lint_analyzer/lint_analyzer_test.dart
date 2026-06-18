import 'dart:io';

import 'package:dart_code_linter/src/analyzers/lint_analyzer/lint_analyzer.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/lint_config.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/models/metric_value_level.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/lint_file_report.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/report.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/no_boolean_literal_compare/no_boolean_literal_compare_rule.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_list/prefer_first_or_null/prefer_first_or_null_rule.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../../stubs_builders.dart';

void main() {
  group(
    'LintAnalyzer',
    () {
      const analyzer = LintAnalyzer();
      const rootDirectory = '';
      final folders = [
        p.normalize(File('test/resources/lint_analyzer').absolute.path),
      ];

      test('should analyze files', () async {
        final config = _createConfig();

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        expect(result, hasLength(4));
      });

      test('should analyze only one file', () async {
        final config = _createConfig(
          excludePatterns: ['test/resources/**/*_exclude_example.dart'],
        );

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        expect(result, hasLength(3));
      });

      test('should report default code metrics', () async {
        final config = _createConfig();

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report =
            reportForFile(result, 'lint_analyzer_exclude_example.dart')
                .functions
                .values
                .first;
        final metrics = {for (final m in report.metrics) m.metricsId: m.level};

        expect(metrics, {
          'cyclomatic-complexity': MetricValueLevel.none,
          'halstead-volume': MetricValueLevel.none,
          'lines-of-code': MetricValueLevel.none,
          'maximum-nesting-level': MetricValueLevel.none,
          'number-of-parameters': MetricValueLevel.none,
          'source-lines-of-code': MetricValueLevel.none,
          'maintainability-index': MetricValueLevel.none,
        });
      });

      test('should exceed lines-of-code metric', () async {
        final config = _createConfig(metrics: {'lines-of-code': 8});

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report =
            reportForFile(result, 'lint_analyzer_exclude_example.dart')
                .functions
                .values
                .first;
        final metrics = {for (final m in report.metrics) m.metricsId: m.level};

        expect(metrics, {
          'cyclomatic-complexity': MetricValueLevel.none,
          'halstead-volume': MetricValueLevel.none,
          'lines-of-code': MetricValueLevel.warning,
          'maximum-nesting-level': MetricValueLevel.none,
          'number-of-parameters': MetricValueLevel.none,
          'source-lines-of-code': MetricValueLevel.none,
          'maintainability-index': MetricValueLevel.none,
        });
      });

      test('should not report metrics', () async {
        final config = _createConfig(
          excludeForMetricsPatterns: ['test/**'],
        );

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report =
            reportForFile(result, 'lint_analyzer_exclude_example.dart')
                .functions
                .values;

        expect(report, isEmpty);
      });

      test(
        'should suppress cyclomatic-complexity metric when ignore_for_file comment is present',
        () async {
          final suppressionFolders = [
            p.normalize(
              File('test/resources/metric_suppression').absolute.path,
            ),
          ];

          final config = _createConfig(
            metrics: {'cyclomatic-complexity': 2},
          );

          final result = await analyzer.runCliAnalysis(
            suppressionFolders,
            rootDirectory,
            config,
          );

          final report = reportForFile(result, 'high_cyclomatic_example.dart');
          final functionMetric = report.functions.values.first;
          final metricsMap = {
            for (final m in functionMetric.metrics) m.metricsId: m.level,
          };

          expect(
            metricsMap['cyclomatic-complexity'],
            equals(MetricValueLevel.none),
          );
        },
      );

      test(
        'should suppress multiple metrics when all are listed in ignore_for_file comment',
        () async {
          final suppressionFolders = [
            p.normalize(
              File('test/resources/metric_suppression').absolute.path,
            ),
          ];

          final config = _createConfig(
            metrics: {
              'cyclomatic-complexity': 2,
              'maximum-nesting-level': 1,
            },
          );

          final result = await analyzer.runCliAnalysis(
            suppressionFolders,
            rootDirectory,
            config,
          );

          final report =
              reportForFile(result, 'multi_metric_suppression_example.dart');
          final functionMetric = report.functions.values.first;
          final metricsMap = {
            for (final m in functionMetric.metrics) m.metricsId: m.level,
          };

          expect(
            metricsMap['cyclomatic-complexity'],
            equals(MetricValueLevel.none),
          );
          expect(
            metricsMap['maximum-nesting-level'],
            equals(MetricValueLevel.none),
          );
        },
      );

      test(
        'should suppress only the named metric and still report violations for others',
        () async {
          final suppressionFolders = [
            p.normalize(
              File('test/resources/metric_suppression').absolute.path,
            ),
          ];

          // nesting=3, threshold=2 → warning (3 > 2 but 3 ≤ 4)
          final config = _createConfig(
            metrics: {
              'cyclomatic-complexity': 2,
              'maximum-nesting-level': 2,
            },
          );

          final result = await analyzer.runCliAnalysis(
            suppressionFolders,
            rootDirectory,
            config,
          );

          final report =
              reportForFile(result, 'selective_suppression_example.dart');
          final functionMetric = report.functions.values.first;
          final metricsMap = {
            for (final m in functionMetric.metrics) m.metricsId: m.level,
          };

          expect(
            metricsMap['cyclomatic-complexity'],
            equals(MetricValueLevel.none),
          );
          expect(
            metricsMap['maximum-nesting-level'],
            equals(MetricValueLevel.warning),
          );
        },
      );

      test(
        'should suppress class-level metric when ignore_for_file comment is present',
        () async {
          final suppressionFolders = [
            p.normalize(
              File('test/resources/metric_suppression').absolute.path,
            ),
          ];

          final config = _createConfig(
            metrics: {'number-of-methods': 2},
          );

          final result = await analyzer.runCliAnalysis(
            suppressionFolders,
            rootDirectory,
            config,
          );

          final report =
              reportForFile(result, 'class_metric_suppression_example.dart');
          final classMetric = report.classes.values.first;
          final metricsMap = {
            for (final m in classMetric.metrics) m.metricsId: m.level,
          };

          expect(
            metricsMap['number-of-methods'],
            equals(MetricValueLevel.none),
          );
        },
      );

      test(
        'should suppress function metric for the targeted function only when '
        'an inline `// ignore:` comment is present',
        () async {
          final suppressionFolders = [
            p.normalize(
              File('test/resources/metric_suppression').absolute.path,
            ),
          ];

          final config = _createConfig(
            metrics: {'cyclomatic-complexity': 2},
          );

          final result = await analyzer.runCliAnalysis(
            suppressionFolders,
            rootDirectory,
            config,
          );

          final report =
              reportForFile(result, 'inline_function_suppression_example.dart');
          final levels = {
            for (final entry in report.functions.entries)
              entry.key: {
                for (final m in entry.value.metrics) m.metricsId: m.level,
              },
          };

          expect(
            levels['suppressedAbove']?['cyclomatic-complexity'],
            equals(MetricValueLevel.none),
          );
          expect(
            levels['suppressedTrailing']?['cyclomatic-complexity'],
            equals(MetricValueLevel.none),
          );
          expect(
            levels['notSuppressed']?['cyclomatic-complexity'],
            isNot(equals(MetricValueLevel.none)),
          );
        },
      );

      test(
        'should suppress class metric for the targeted class only when '
        'an inline `// ignore:` comment is present',
        () async {
          final suppressionFolders = [
            p.normalize(
              File('test/resources/metric_suppression').absolute.path,
            ),
          ];

          final config = _createConfig(
            metrics: {'number-of-methods': 2},
          );

          final result = await analyzer.runCliAnalysis(
            suppressionFolders,
            rootDirectory,
            config,
          );

          final report =
              reportForFile(result, 'inline_class_suppression_example.dart');
          final levels = {
            for (final entry in report.classes.entries)
              entry.key: {
                for (final m in entry.value.metrics) m.metricsId: m.level,
              },
          };

          expect(
            levels['SuppressedAbove']?['number-of-methods'],
            equals(MetricValueLevel.none),
          );
          expect(
            levels['SuppressedTrailing']?['number-of-methods'],
            equals(MetricValueLevel.none),
          );
          expect(
            levels['NotSuppressed']?['number-of-methods'],
            isNot(equals(MetricValueLevel.none)),
          );
        },
      );

      test(
        'inline `// ignore:` for one metric must not suppress sibling metrics',
        () async {
          final suppressionFolders = [
            p.normalize(
              File('test/resources/metric_suppression').absolute.path,
            ),
          ];

          final config = _createConfig(
            metrics: {
              'cyclomatic-complexity': 2,
              'maximum-nesting-level': 2,
            },
          );

          final result = await analyzer.runCliAnalysis(
            suppressionFolders,
            rootDirectory,
            config,
          );

          final report = reportForFile(
            result,
            'inline_selective_suppression_example.dart',
          );
          final functionMetric = report.functions.values.first;
          final metricsMap = {
            for (final m in functionMetric.metrics) m.metricsId: m.level,
          };

          expect(
            metricsMap['cyclomatic-complexity'],
            equals(MetricValueLevel.none),
          );
          expect(
            metricsMap['maximum-nesting-level'],
            isNot(equals(MetricValueLevel.none)),
          );
        },
      );

      test('should report no-magic-number rule', () async {
        final config = _createConfig(rules: {'no-magic-number': {}});

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final issues =
            reportForFile(result, 'lint_analyzer_exclude_example.dart').issues;

        expect(
          issues.map((issue) => issue.ruleId),
          equals(['no-magic-number', 'no-magic-number']),
        );
      });

      test('should not report rules', () async {
        final config = _createConfig(
          rules: {'avoid-late-keyword': {}},
          excludeForRulesPatterns: ['test/**'],
        );

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report =
            reportForFile(result, 'lint_analyzer_exclude_example.dart').issues;
        expect(report, isEmpty);
      });

      test('collect summary for passed empty report', () {
        final result = analyzer.getSummary([]);

        expect(
          result.firstWhere((r) => r.title == 'Scanned folders').value,
          isEmpty,
        );

        expect(
          result.firstWhere((r) => r.title == 'Total scanned files').value,
          isZero,
        );

        expect(
          result.firstWhere((r) => r.title == 'Total tech debt').value,
          equals('not found'),
        );
      });

      test('collect summary for passed report', () {
        final result = analyzer.getSummary([
          LintFileReport(
            path: '/home/dev/project/bin/example.dart',
            relativePath: 'bin/example.dart',
            file: buildReportStub(metrics: [
              buildMetricValueStub(
                id: 'technical-debt',
                value: 10,
                unitType: 'USD',
              ),
            ]),
            classes: Map.unmodifiable(<String, Report>{}),
            functions: Map.unmodifiable(<String, Report>{}),
            issues: const [],
            antiPatternCases: const [],
          ),
          LintFileReport(
            path: '/home/dev/project/lib/example.dart',
            relativePath: 'lib/example.dart',
            file: buildReportStub(),
            classes: Map.unmodifiable(<String, Report>{}),
            functions: Map.unmodifiable(<String, Report>{}),
            issues: const [],
            antiPatternCases: const [],
          ),
        ]);

        expect(
          result.firstWhere((r) => r.title == 'Scanned folders').value,
          containsAll(<String>['bin', 'lib']),
        );
        expect(
          result.firstWhere((r) => r.title == 'Total scanned files').value,
          equals(2),
        );
        expect(
          result.firstWhere((r) => r.title == 'Total tech debt').value,
          equals('10 USD'),
        );
      });

      test('should not fix files', () async {
        final basePath =
            '${Directory.current.path}/test/resources/lint_analyzer';
        final fixedExamplePath = '$basePath/lint_fix_fixed_example.dart';

        final originalFixedExampleContent =
            await File(fixedExamplePath).readAsString();

        final config = _createConfig(
          excludePatterns: [
            'test/resources/lint_analyzer/lint_analyzer_example.dart',
            'test/resources/lint_analyzer/lint_analyzer_exclude_example.dart',
            'test/resources/lint_analyzer/lint_fix_original_example.dart',
          ],
          rules: {
            PreferFirstOrNullRule.ruleId: {},
          },
        );

        await analyzer.runCliFix(
          folders,
          rootDirectory,
          config,
        );

        final fixedExampleContent = await File(fixedExamplePath).readAsString();

        expect(
          originalFixedExampleContent,
          equals(fixedExampleContent),
        );
      });

      test('should fix files', () async {
        final basePath =
            '${Directory.current.path}/test/resources/lint_analyzer';
        final originalExamplePath = '$basePath/lint_fix_original_example.dart';
        final fixedExamplePath = '$basePath/lint_fix_fixed_example.dart';

        final originalExampleContent =
            await File(originalExamplePath).readAsString();

        final config = _createConfig(
          rules: {
            PreferFirstOrNullRule.ruleId: {},
          },
        );

        await analyzer.runCliFix(
          folders,
          rootDirectory,
          config,
        );

        final modifiedExampleContent =
            await File(originalExamplePath).readAsString();
        final fixedExampleContent = await File(fixedExamplePath).readAsString();

        expect(
          modifiedExampleContent,
          equals(fixedExampleContent),
        );

        await File(originalExamplePath).writeAsString(originalExampleContent);
      });

      test('should fix files with multiple issues (issue #188)', () async {
        final basePath =
            '${Directory.current.path}/test/resources/lint_analyzer_fix_multiple';
        final originalExamplePath =
            '$basePath/multiple_fixes_original_example.dart';
        final fixedExamplePath = '$basePath/multiple_fixes_fixed_example.dart';

        final originalExampleContent =
            await File(originalExamplePath).readAsString();

        final config = _createConfig(
          rules: {
            NoBooleanLiteralCompareRule.ruleId: {},
          },
        );

        final multipleFolders = [
          p.normalize(
            File('test/resources/lint_analyzer_fix_multiple').absolute.path,
          ),
        ];

        try {
          await analyzer.runCliFix(
            multipleFolders,
            rootDirectory,
            config,
          );

          final modifiedExampleContent =
              await File(originalExamplePath).readAsString();
          final fixedExampleContent =
              await File(fixedExamplePath).readAsString();

          expect(
            modifiedExampleContent,
            equals(fixedExampleContent),
          );
        } finally {
          await File(originalExamplePath).writeAsString(originalExampleContent);
        }
      });

      test('runCliFix flushes file writes before returning (issue #188)',
          () async {
        // Regression guard: the fix must be written to disk before runCliFix
        // returns. We read back synchronously (no event-loop yield) so that a
        // fire-and-forget, unawaited write would deterministically be observed
        // as stale content here.
        final basePath =
            '${Directory.current.path}/test/resources/lint_analyzer_fix_multiple';
        final originalExamplePath =
            '$basePath/multiple_fixes_original_example.dart';
        final fixedExamplePath = '$basePath/multiple_fixes_fixed_example.dart';

        final originalExampleContent =
            await File(originalExamplePath).readAsString();

        final config = _createConfig(
          rules: {
            NoBooleanLiteralCompareRule.ruleId: {},
          },
        );

        final multipleFolders = [
          p.normalize(
            File('test/resources/lint_analyzer_fix_multiple').absolute.path,
          ),
        ];

        try {
          await analyzer.runCliFix(
            multipleFolders,
            rootDirectory,
            config,
          );

          final onDisk = File(originalExamplePath).readAsStringSync();
          final fixedExampleContent =
              await File(fixedExamplePath).readAsString();

          expect(onDisk, equals(fixedExampleContent));
        } finally {
          await File(originalExamplePath).writeAsString(originalExampleContent);
        }
      });
    },
    testOn: 'posix',
  );
}

LintConfig _createConfig({
  Map<String, Map<String, Object>> antiPatterns = const {},
  Iterable<String> excludePatterns = const [],
  Map<String, Object> metrics = const {},
  Iterable<String> excludeForMetricsPatterns = const [],
  Map<String, Map<String, Object>> rules = const {},
  Iterable<String> excludeForRulesPatterns = const [],
  bool shouldPrintConfig = false,
  String analysisOptionsPath = '',
}) =>
    LintConfig(
      antiPatterns: antiPatterns,
      excludePatterns: excludePatterns,
      metrics: metrics,
      excludeForMetricsPatterns: excludeForMetricsPatterns,
      rules: rules,
      excludeForRulesPatterns: excludeForRulesPatterns,
      shouldPrintConfig: shouldPrintConfig,
      analysisOptionsPath: analysisOptionsPath,
    );

LintFileReport reportForFile(
  Iterable<LintFileReport> reports,
  String fileName,
) =>
    reports.firstWhere((report) => report.relativePath.endsWith(fileName));
