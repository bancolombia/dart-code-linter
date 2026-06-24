import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_code_linter/src/utils/ast_compat.dart';
import 'package:test/test.dart';

CompilationUnit _parse(String source) => parseString(
      content: source,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    ).unit;

T _firstOfType<T extends AstNode>(AstNode root) {
  final hits = <T>[];
  _walk(root, (node) {
    if (node is T) {
      hits.add(node);
    }
  });
  return hits.first;
}

void _walk(AstNode node, void Function(AstNode) visit) {
  visit(node);
  for (final child in node.childEntities) {
    if (child is AstNode) {
      _walk(child, visit);
    }
  }
}

void main() {
  group('asNamedArgument', () {
    test('recognises a named argument in an argument list', () {
      final unit = _parse('void main() { foo(answer: 42); }');
      final call = _firstOfType<MethodInvocation>(unit);
      final firstArg = call.argumentList.arguments.first;

      final view = asNamedArgument(firstArg);

      expect(view, isNotNull);
      expect(view!.name, equals('answer'));
      expect(view.expression.toSource(), equals('42'));
    });

    test('recognises a named field in a record literal', () {
      final unit = _parse('final r = (answer: 42, name: "x");');
      final record = _firstOfType<RecordLiteral>(unit);

      final view = asNamedArgument(record.fields.first);

      expect(view, isNotNull);
      expect(view!.name, equals('answer'));
      expect(view.expression.toSource(), equals('42'));
    });

    test('returns null for a positional argument', () {
      final unit = _parse('void main() { foo(42, 43); }');
      final call = _firstOfType<MethodInvocation>(unit);

      expect(asNamedArgument(call.argumentList.arguments.first), isNull);
      expect(asNamedArgument(call.argumentList.arguments.last), isNull);
    });

    test('returns null for a labeled statement (Label child, not a named arg)',
        () {
      final unit = _parse('void main() { outer: for (;;) { break outer; } }');
      final labeled = _firstOfType<LabeledStatement>(unit);

      // LabeledStatement has Label children, but is not a named argument.
      expect(asNamedArgument(labeled), isNull);
    });

    test('returns null for an arbitrary expression', () {
      final unit = _parse('void main() { var x = 1 + 2; }');
      final binary = _firstOfType<BinaryExpression>(unit);

      expect(asNamedArgument(binary), isNull);
    });

    test('isNamedArgument mirrors asNamedArgument', () {
      final unit = _parse('void main() { foo(named: 1); }');
      final call = _firstOfType<MethodInvocation>(unit);
      final namedArg = call.argumentList.arguments.first;

      expect(isNamedArgument(namedArg), isTrue);
      expect(isNamedArgument(42), isFalse);
      expect(isNamedArgument(null), isFalse);
    });
  });

  group('unwrapArgumentExpression', () {
    test('unwraps a named argument to its inner Expression', () {
      final unit = _parse('void main() { foo(answer: 42); }');
      final call = _firstOfType<MethodInvocation>(unit);
      final arg = call.argumentList.arguments.first;

      final expr = unwrapArgumentExpression(arg);

      expect(expr, isNotNull);
      expect(expr!.toSource(), equals('42'));
    });

    test('returns a positional Expression as-is', () {
      final unit = _parse('void main() { foo(42); }');
      final call = _firstOfType<MethodInvocation>(unit);
      final arg = call.argumentList.arguments.first;

      expect(identical(unwrapArgumentExpression(arg), arg), isTrue);
    });

    test('returns null for a non-Expression, non-named-arg node', () {
      expect(unwrapArgumentExpression('not an ast node'), isNull);
      expect(unwrapArgumentExpression(null), isNull);
    });
  });

  group('argumentExpressions', () {
    test('yields positional and unwrapped named expressions in order', () {
      final unit = _parse('void main() { foo(1, named: 2, 3); }');
      final call = _firstOfType<MethodInvocation>(unit);

      final exprs =
          argumentExpressions(call.argumentList).map((e) => e.toSource());

      expect(exprs, equals(['1', '2', '3']));
    });
  });

  group('defaultParameterValue', () {
    test('returns the Expression for an explicit default', () {
      final unit = _parse('void f([String? value = "fallback"]) {}');
      final param = _firstOfType<FormalParameter>(unit);

      final value = defaultParameterValue(param);

      expect(value, isNotNull);
      expect(value!.toSource(), equals('"fallback"'));
    });

    test(
        'returns null for an optional typed parameter without a default '
        '(regression: type name must not be returned as the default)', () {
      final unit = _parse('void f([String? value]) {}');
      final param = _firstOfType<FormalParameter>(unit);

      expect(defaultParameterValue(param), isNull);
    });

    test('returns null for a required typed parameter', () {
      final unit = _parse('void f(String value) {}');
      final param = _firstOfType<FormalParameter>(unit);

      expect(defaultParameterValue(param), isNull);
    });

    test('returns the Expression for a named parameter default', () {
      final unit = _parse('void f({int count = 7}) {}');
      final param = _firstOfType<FormalParameter>(unit);

      final value = defaultParameterValue(param);

      expect(value, isNotNull);
      expect(value!.toSource(), equals('7'));
    });

    test('handles generic typed optional parameter without a default', () {
      final unit = _parse('void f([List<int>? xs]) {}');
      final param = _firstOfType<FormalParameter>(unit);

      expect(defaultParameterValue(param), isNull);
    });
  });

  group('runtime-type allowlist invariant', () {
    test('structural shape and runtime-type allowlist agree on all nodes', () {
      final unit = _parse('''
        void main() {
          foo(1, named: 2, other: bar());
          baz(answer: 42);
          final r = (1, 2, answer: 42, name: 'x');
          outer: for (;;) { break outer; }
          inner: for (;;) { continue inner; }
          final m = {'k': 'v', 'x': 1};
          final c = true ? 1 : 2;
        }

        void f(int a, {int count = 7, String? value, List<int>? xs}) {}
        void g([String? s = 'x', int n = 1]) {}
      ''');

      final mismatches = <String>[];
      _walk(unit, (node) {
        final structureMatches = debugMatchesNamedArgumentShape(node);
        final inAllowlist =
            debugNamedArgumentRuntimeTypes.contains(node.runtimeType.toString());
        if (structureMatches != inAllowlist) {
          mismatches.add(
            '${node.runtimeType}: structure=$structureMatches '
            'allowlist=$inAllowlist source="${node.toSource()}"',
          );
        }
      });

      expect(
        mismatches,
        isEmpty,
        reason: 'Update _namedArgumentRuntimeTypes in ast_compat.dart. '
            'Mismatches: $mismatches',
      );
    });
  });

  group('labelName', () {
    test('returns the identifier text', () {
      final unit = _parse('void main() { foo(answer: 1); }');
      final call = _firstOfType<MethodInvocation>(unit);
      final view = asNamedArgument(call.argumentList.arguments.first)!;

      expect(view.name, equals('answer'));
    });
  });

  group('extensionTypeName', () {
    ExtensionTypeDeclaration parseExtensionType(String source) =>
        _firstOfType<ExtensionTypeDeclaration>(_parse(source));

    test('returns the name of a simple extension type', () {
      final node = parseExtensionType('extension type Meters(int value) {}');

      expect(extensionTypeName(node), equals('Meters'));
    });

    test('returns the name of a const extension type', () {
      final node =
          parseExtensionType('extension type const Id(String value) {}');

      expect(extensionTypeName(node), equals('Id'));
    });

    test('returns the name when a named primary constructor is present', () {
      final node = parseExtensionType(
        'extension type Wrapper.of(int value) {}',
      );

      expect(extensionTypeName(node), equals('Wrapper'));
    });

    test('returns the name of a generic extension type', () {
      final node = parseExtensionType('extension type Box<T>(T value) {}');

      expect(extensionTypeName(node), equals('Box'));
    });

    test('returns the name when an implements clause is present', () {
      final node = parseExtensionType(
        'extension type Celsius(double value) implements num {}',
      );

      expect(extensionTypeName(node), equals('Celsius'));
    });

    test(
      'structural anchor holds: the name part is the first child node and its '
      'first identifier token is the type name (validated per analyzer row)',
      () {
        const cases = {
          'extension type Meters(int value) {}': 'Meters',
          'extension type const Id(String value) {}': 'Id',
          'extension type Wrapper.of(int value) {}': 'Wrapper',
          'extension type Box<T>(T value) {}': 'Box',
          'extension type Celsius(double value) implements num {}': 'Celsius',
        };

        for (final entry in cases.entries) {
          final node = parseExtensionType(entry.key);
          final namePart = debugExtensionTypeNamePart(node);

          expect(
            namePart,
            isNotNull,
            reason: 'No name-part node resolved for "${entry.key}". '
                'ExtensionTypeDeclaration child shape changed in this '
                'analyzer version.',
          );
          // The name part must precede the implements clause and body.
          expect(
            namePart,
            isNot(isA<ImplementsClause>()),
            reason: 'Resolved the implements clause instead of the name part '
                'for "${entry.key}".',
          );
          expect(extensionTypeName(node), equals(entry.value));
        }
      },
    );
  });
}
