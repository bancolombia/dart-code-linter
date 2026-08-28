import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/metrics_list/cognitive_complexity/cognitive_complexity_flow_visitor.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/metrics/scope_visitor.dart';
import 'package:test/test.dart';

import '../../../../../helpers/file_resolver.dart';

const _examplePath =
    './test/resources/cognitive_complexity_metric_example.dart';

const _rulesExamplePath =
    './test/resources/cognitive_complexity_rules_example.dart';

Future<void> main() async {
  final result = await FileResolver.resolve(_examplePath);
  final rulesResult = await FileResolver.resolve(_rulesExamplePath);

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

  group('CognitiveComplexityFlowVisitor scores', () {
    final scopeVisitor = ScopeVisitor();
    rulesResult.unit.visitChildren(scopeVisitor);

    test('a switch and all of its cases as a single increment', () {
      expect(
        _scoresOf(scopeVisitor, 'switchStatement'),
        equals(['Switch statement: 1', 'If statement: 2']),
      );
    });

    test('every catch clause, ignoring the try and finally blocks', () {
      expect(
        _scoresOf(scopeVisitor, 'catchClauses'),
        equals([
          'If statement: 1',
          'Catch clause: 1',
          'If statement: 2',
          'Catch clause: 1',
          'If statement: 2',
          'If statement: 1',
        ]),
      );
    });

    test('a ternary operator with a nesting increment', () {
      expect(
        _scoresOf(scopeVisitor, 'ternaryOperator'),
        equals(['Conditional expression: 1', 'Conditional expression: 2']),
      );
    });

    test("the white paper's sumOfPrimes example at 7", () {
      expect(
        _scoresOf(scopeVisitor, 'sumOfPrimes'),
        equals([
          'For statement: 1',
          'For statement: 2',
          'If statement: 3',
          'Labeled continue statement: 1',
        ]),
      );
      expect(_complexityOf(scopeVisitor, 'sumOfPrimes'), equals(7));
    });

    test('nothing for unlabeled break, continue and return', () {
      expect(
        _scoresOf(scopeVisitor, 'unlabeledJumps'),
        equals(['For statement: 1', 'If statement: 2', 'If statement: 2']),
      );
    });

    test('a closure as a nesting level rather than an increment', () {
      expect(
        _scoresOf(scopeVisitor, 'closureNesting'),
        equals(['If statement: 2']),
      );
    });

    test('a closure inside a loop as two stacked nesting levels', () {
      expect(
        _scoresOf(scopeVisitor, 'closureInsideLoop'),
        equals(['For statement: 1', 'If statement: 3']),
      );
    });

    test('else and else if as hybrid increments that still raise nesting', () {
      expect(
        _scoresOf(scopeVisitor, 'elseIfChain'),
        equals([
          'If statement: 1',
          'If statement: 2',
          'Else if statement: 1',
          'If statement: 2',
          'Else statement: 1',
          'If statement: 2',
        ]),
      );
    });

    test('each sequence of like binary logical operators once', () {
      expect(
        _scoresOf(scopeVisitor, 'mixedOperatorSequences'),
        equals([
          'If statement: 1',
          'Operator ||: 1',
          'Operator &&: 1',
          'Operator &&: 1',
        ]),
      );
    });

    test('a negated sequence separately from the one containing it', () {
      expect(
        _scoresOf(scopeVisitor, 'negatedOperatorSequence'),
        equals(['If statement: 1', 'Operator &&: 1', 'Operator &&: 1']),
      );
    });

    test('a sequence of like operators outside a condition', () {
      expect(
        _scoresOf(scopeVisitor, 'operatorSequenceInReturn'),
        equals(['Operator &&: 1']),
      );
    });
  });

  // The specification assesses increments for these structures, so every
  // expectation below pins a known gap rather than the intended behaviour.
  // Each one should be updated, not deleted, once the gap is closed.
  group('CognitiveComplexityFlowVisitor does not yet score', () {
    final scopeVisitor = ScopeVisitor();
    rulesResult.unit.visitChildren(scopeVisitor);

    test('collection-literal if and for', () {
      expect(
        _complexityOf(scopeVisitor, 'collectionLiteralControlFlow'),
        equals(0),
      );
    });

    test('a switch expression', () {
      expect(_complexityOf(scopeVisitor, 'switchExpression'), equals(0));
    });

    test('the guard of an if-case clause', () {
      expect(
        _scoresOf(scopeVisitor, 'ifCaseGuard'),
        equals(['If statement: 1']),
      );
    });

    test('a recursion cycle once instead of once per call site', () {
      expect(
        _scoresOf(scopeVisitor, 'fibonacci'),
        equals(['If statement: 1', 'Recursive call: 1', 'Recursive call: 1']),
      );
    });

    test('a recursive call made through an explicit this', () {
      expect(
        _scoresOf(scopeVisitor, 'factorial'),
        equals(['If statement: 1']),
      );
    });
  });
}

CognitiveComplexityFlowVisitor _visitorFor(ScopeVisitor scope, String name) {
  final declaration = scope.functions
      .map((function) => function.declaration)
      .firstWhere((declaration) => _nameOf(declaration) == name);

  final visitor = CognitiveComplexityFlowVisitor(
    root: declaration,
    functionName: name,
  );
  declaration.visitChildren(visitor);

  return visitor;
}

Iterable<String> _scoresOf(ScopeVisitor scope, String name) => _visitorFor(
      scope,
      name,
    ).scoredEntities.map((entity) => '${entity.description}: ${entity.score}');

int _complexityOf(ScopeVisitor scope, String name) =>
    _visitorFor(scope, name).complexity;

String? _nameOf(Declaration declaration) {
  if (declaration is FunctionDeclaration) {
    return declaration.name.lexeme;
  } else if (declaration is MethodDeclaration) {
    return declaration.name.lexeme;
  }

  return null;
}
