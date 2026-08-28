import 'package:analyzer/dart/ast/ast.dart';

import '../../../../../utils/node_utils.dart';
import '../../../models/context_message.dart';
import '../../../models/entity_type.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/scoped_class_declaration.dart';
import '../../../models/scoped_function_declaration.dart';
import '../../metric_utils.dart';
import '../../models/function_metric.dart';
import '../../models/metric_computation_result.dart';
import '../../models/metric_documentation.dart';
import '../../models/metric_value.dart';
import 'cognitive_complexity_flow_visitor.dart';

const _documentation = MetricDocumentation(
  name: 'Cognitive Complexity',
  shortName: 'COGNITIVE',
  measuredType: EntityType.methodEntity,
  recommendedThreshold: 20,
);

/// Cognitive Complexity (COGNITIVE)
///
/// Cognitive complexity is a measure of how difficult the code is for a
/// human to read and understand, based on SonarSource's Cognitive Complexity
/// algorithm. Unlike cyclomatic complexity, it penalizes control flow that
/// is nested more heavily than the same control flow written flat.
///
/// The scoring rules, how they map onto Dart, and the gaps the implementation
/// still has are documented in `docs/cognitive-complexity/`.
class CognitiveComplexityMetric extends FunctionMetric<int> {
  static const String metricId = 'cognitive-complexity';

  /// Initialize a newly created [CognitiveComplexityMetric] with passed [config].
  CognitiveComplexityMetric({Map<String, Object> config = const {}})
      : super(
          id: metricId,
          documentation: _documentation,
          threshold: readNullableThreshold<int>(config, metricId),
          levelComputer: valueLevel,
        );

  @override
  MetricComputationResult<int> computeImplementation(
    AstNode node,
    Iterable<ScopedClassDeclaration> classDeclarations,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    InternalResolvedUnitResult source,
    Iterable<MetricValue> otherMetricsValues,
  ) {
    final visitor = CognitiveComplexityFlowVisitor(
      root: node,
      functionName: _functionName(node),
    );
    node.visitChildren(visitor);

    return MetricComputationResult(
      value: visitor.complexity,
      context: _context(visitor.scoredEntities, source),
    );
  }

  @override
  String commentMessage(String nodeType, int value, int? threshold) {
    final exceeds = threshold != null && value > threshold
        ? ', which exceeds the maximum of $threshold allowed'
        : '';

    return 'This $nodeType has a cognitive complexity of $value$exceeds.';
  }

  String? _functionName(AstNode node) {
    if (node is FunctionDeclaration) {
      return node.name.lexeme;
    } else if (node is MethodDeclaration) {
      return node.name.lexeme;
    }

    return null;
  }

  Iterable<ContextMessage> _context(
    Iterable<CognitiveComplexityEntity> scoredEntities,
    InternalResolvedUnitResult source,
  ) =>
      scoredEntities
          .map((scored) => ContextMessage(
                message:
                    '${scored.description} increases complexity by ${scored.score}',
                location: nodeLocation(node: scored.entity, source: source),
              ))
          .toList()
        ..sort((a, b) => a.location.start.compareTo(b.location.start));
}
