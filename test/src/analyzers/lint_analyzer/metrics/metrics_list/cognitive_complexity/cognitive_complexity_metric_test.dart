import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/metrics_list/cognitive_complexity/cognitive_complexity_metric.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/models/metric_value_level.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/scope_visitor.dart';
import 'package:test/test.dart';

import '../../../../../helpers/file_resolver.dart';

const _examplePath =
    './test/resources/cognitive_complexity_metric_example.dart';

Future<void> main() async {
  final metric = CognitiveComplexityMetric(
    config: {CognitiveComplexityMetric.metricId: '5'},
  );

  final example = await FileResolver.resolve(_examplePath);

  group('CognitiveComplexityMetric computes cognitive complexity of the', () {
    final scopeVisitor = ScopeVisitor();
    example.unit.visitChildren(scopeVisitor);

    test('flat function', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.first.declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
        [],
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(5));
      expect(metricValue.level, equals(MetricValueLevel.noted));
      expect(
        metricValue.comment,
        equals('This function has a cognitive complexity of 5.'),
      );
      expect(
        metricValue.context.map((e) => e.message),
        equals([
          'If statement increases complexity by 1',
          'Else if statement increases complexity by 1',
          'Else statement increases complexity by 1',
          'For statement increases complexity by 1',
          'Operator && increases complexity by 1',
        ]),
      );
    });

    test('nested function', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[1].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
        [],
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(6));
      expect(metricValue.level, equals(MetricValueLevel.warning));
      expect(
        metricValue.comment,
        equals(
          'This function has a cognitive complexity of 6, which exceeds the maximum of 5 allowed.',
        ),
      );
      expect(
        metricValue.context.map((e) => e.message),
        equals([
          'For statement increases complexity by 1',
          'If statement increases complexity by 2',
          'While statement increases complexity by 3',
        ]),
      );
    });

    test('empty function', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[2].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
        [],
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(0));
      expect(metricValue.level, equals(MetricValueLevel.none));
      expect(
        metricValue.comment,
        equals('This function has a cognitive complexity of 0.'),
      );
      expect(metricValue.context, isEmpty);
    });

    test('recursive function', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[3].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
        [],
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(2));
      expect(metricValue.level, equals(MetricValueLevel.none));
      expect(
        metricValue.comment,
        equals('This function has a cognitive complexity of 2.'),
      );
      expect(
        metricValue.context.map((e) => e.message),
        equals([
          'If statement increases complexity by 1',
          'Recursive call increases complexity by 1',
        ]),
      );
    });
  });
}
