import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/metrics_list/cognitive_complexity/cognitive_complexity_flow_visitor.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/scope_visitor.dart';
import 'package:test/test.dart';

import '../../../../../helpers/file_resolver.dart';

const _examplePath =
    './test/resources/cognitive_complexity_metric_example.dart';

Future<void> main() async {
  final result = await FileResolver.resolve(_examplePath);

  group(
    'CognitiveComplexityFlowVisitor collect information about cognitive complexity in',
    () {
      final scopeVisitor = ScopeVisitor();
      result.unit.visitChildren(scopeVisitor);

      test('flat function', () {
        final declaration = scopeVisitor.functions.first.declaration;

        final visitor = CognitiveComplexityFlowVisitor(root: declaration);
        declaration.visitChildren(visitor);

        expect(visitor.complexity, equals(5));
        expect(visitor.scoredEntities, hasLength(5));
      });

      test('nested function', () {
        final declaration = scopeVisitor.functions.toList()[1].declaration;

        final visitor = CognitiveComplexityFlowVisitor(root: declaration);
        declaration.visitChildren(visitor);

        expect(visitor.complexity, equals(6));
        expect(
          visitor.scoredEntities.map((e) => e.score),
          equals([1, 2, 3]),
        );
      });

      test('empty function', () {
        final declaration = scopeVisitor.functions.toList()[2].declaration;

        final visitor = CognitiveComplexityFlowVisitor(root: declaration);
        declaration.visitChildren(visitor);

        expect(visitor.complexity, equals(0));
        expect(visitor.scoredEntities, isEmpty);
      });

      test(
          'recursive function without a function name does not score recursion',
          () {
        final declaration = scopeVisitor.functions.toList()[3].declaration;

        final visitor = CognitiveComplexityFlowVisitor(root: declaration);
        declaration.visitChildren(visitor);

        expect(visitor.complexity, equals(1));
      });

      test('recursive function with a function name scores the recursive call',
          () {
        final declaration = scopeVisitor.functions.toList()[3].declaration
            as FunctionDeclaration;

        final visitor = CognitiveComplexityFlowVisitor(
          root: declaration,
          functionName: declaration.name.lexeme,
        );
        declaration.visitChildren(visitor);

        expect(visitor.complexity, equals(2));
        expect(
          visitor.scoredEntities.map((e) => e.description),
          equals(['If statement', 'Recursive call']),
        );
      });
    },
  );
}
