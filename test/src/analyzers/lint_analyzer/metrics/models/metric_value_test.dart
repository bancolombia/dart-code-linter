import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/models/metric_value_level.dart';
import 'package:test/test.dart';

import '../../../../../stubs_builders.dart';

void main() {
  group('MetricValue', () {
    test('suppressed() overrides level to none regardless of original level',
        () {
      for (final level in [
        MetricValueLevel.noted,
        MetricValueLevel.warning,
        MetricValueLevel.alarm,
      ]) {
        final mv = buildMetricValueStub<int>(
          id: 'cyclomatic-complexity',
          value: 15,
          level: level,
        );
        expect(
          mv.suppressed().level,
          equals(MetricValueLevel.none),
          reason: 'Expected suppressed() to return none for level $level',
        );
      }
    });

    test('suppressed() returns none even when level is already none', () {
      final mv = buildMetricValueStub<int>(
        id: 'cyclomatic-complexity',
        value: 1,
        level: MetricValueLevel.none,
      );
      expect(mv.suppressed().level, equals(MetricValueLevel.none));
    });

    test('suppressed() preserves all fields except level', () {
      final mv = buildMetricValueStub<int>(
        id: 'cyclomatic-complexity',
        value: 15,
        level: MetricValueLevel.warning,
        unitType: 'ops',
      );
      final suppressed = mv.suppressed();

      expect(suppressed.metricsId, equals(mv.metricsId));
      expect(suppressed.documentation, equals(mv.documentation));
      expect(suppressed.value, equals(mv.value));
      expect(suppressed.unitType, equals(mv.unitType));
      expect(suppressed.comment, equals(mv.comment));
      expect(suppressed.recommendation, equals(mv.recommendation));
      expect(suppressed.context, equals(mv.context));
    });
  });
}
