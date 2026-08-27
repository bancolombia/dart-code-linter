import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_code_linter/src/utils/ast_compat.dart';
import 'package:test/test.dart';

import '../helpers/file_resolver.dart';

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

  group('isAbstractMethod', () {
    MethodDeclaration parseMethod(String source) =>
        _firstOfType<MethodDeclaration>(_parse(source));

    test('is true for an abstract method (no body, not external)', () {
      final node = parseMethod('abstract class A { void foo(); }');

      expect(isAbstractMethod(node), isTrue);
    });

    test('is false for a method with a body', () {
      final node = parseMethod('class A { void foo() {} }');

      expect(isAbstractMethod(node), isFalse);
    });

    test('is false for an arrow-bodied method', () {
      final node = parseMethod('class A { int foo() => 1; }');

      expect(isAbstractMethod(node), isFalse);
    });

    test('is false for an external method (complete, not abstract)', () {
      final node = parseMethod('class A { external void foo(); }');

      expect(isAbstractMethod(node), isFalse);
    });

    test('matches MethodDeclaration.isAbstract on the current analyzer', () {
      const sources = [
        'abstract class A { void foo(); }',
        'class A { void foo() {} }',
        'class A { int foo() => 1; }',
        'class A { external void foo(); }',
      ];

      for (final source in sources) {
        final node = parseMethod(source);
        expect(
          isAbstractMethod(node),
          // ignore: deprecated_member_use
          equals(node.isAbstract),
          reason: 'Diverged from analyzer isAbstract for: $source',
        );
      }
    });
  });

  group('correspondingParameterOf', () {
    // Unlike the other helpers, correspondingParameterOf needs resolved
    // elements, so the fixture goes through FileResolver instead of
    // parseString.
    const fixturePath =
        'test/src/utils/corresponding_parameter_of_fixture.dart';
    const fixtureContent = '''
class Config {
  Config({int? retries});
}

void send(int attempts, {String? label}) {}

void main() {
  send(1, label: 'x');
  Config(retries: 3);
  final sum = 1 + 2;
  print(sum);
}
''';

    late CompilationUnit unit;

    setUpAll(() async {
      final file = File(fixturePath)..writeAsStringSync(fixtureContent);
      try {
        unit = (await FileResolver.resolve(fixturePath)).unit;
      } finally {
        file.deleteSync();
      }
    });

    test('resolves a positional argument to its parameter', () {
      final call = _firstOfType<MethodInvocation>(unit);
      final positional = unwrapArgumentExpression(
        call.argumentList.arguments.first,
      )!;

      final parameter = correspondingParameterOf(positional);

      expect(parameter, isNotNull);
      expect(parameter!.name, equals('attempts'));
    });

    test('resolves a named argument to its parameter', () {
      final call = _firstOfType<MethodInvocation>(unit);
      final named = unwrapArgumentExpression(
        call.argumentList.arguments.last,
      )!;

      final parameter = correspondingParameterOf(named);

      expect(parameter, isNotNull);
      expect(parameter!.name, equals('label'));
    });

    test('resolves a named constructor argument to its parameter', () {
      final creation = _firstOfType<InstanceCreationExpression>(unit);
      final named = unwrapArgumentExpression(
        creation.argumentList.arguments.first,
      )!;

      final parameter = correspondingParameterOf(named);

      expect(parameter, isNotNull);
      expect(parameter!.name, equals('retries'));
    });

    test('returns null for an expression that is not a call argument', () {
      final binary = _firstOfType<BinaryExpression>(unit);

      expect(correspondingParameterOf(binary), isNull);
    });
  });

  group('typeDeclarationName', () {
    // These must hold on both child shapes the matrix covers: analyzer 8.2-9.0
    // keep the name as a direct token of the declaration, 10.0+ move it into a
    // name-part child node. Modifier keywords that tokenize as contextual
    // identifiers (`base`, `sealed`) are why the anchor is the `class`/`enum`
    // keyword rather than simply the first identifier.
    const classCases = {
      'class Simple {}': 'Simple',
      'abstract class Abstract {}': 'Abstract',
      'final class Modifiers {}': 'Modifiers',
      'sealed class Sealed {}': 'Sealed',
      'base class Base {}': 'Base',
      'class Generic<T> {}': 'Generic',
      'class Extending extends Object {}': 'Extending',
      'class Implementing implements Comparable<int> {}': 'Implementing',
      'class _Private {}': '_Private',
    };

    for (final entry in classCases.entries) {
      test('reads the class name from "${entry.key}"', () {
        final node = _firstOfType<ClassDeclaration>(_parse(entry.key));

        expect(typeDeclarationName(node), equals(entry.value));
        expect(typeDeclarationNameToken(node)?.lexeme, equals(entry.value));
      });
    }

    const enumCases = {
      'enum Simple { a }': 'Simple',
      'enum Generic<T> { a }': 'Generic',
      'enum WithMembers { a; const WithMembers(); }': 'WithMembers',
    };

    for (final entry in enumCases.entries) {
      test('reads the enum name from "${entry.key}"', () {
        final node = _firstOfType<EnumDeclaration>(_parse(entry.key));

        expect(typeDeclarationName(node), equals(entry.value));
      });
    }

    // A doc comment and metadata are listed first in `childEntities`, ahead of
    // the declaration's own children, so reading the name must step over them.
    const decoratedCases = {
      '/// Doc.\nclass Documented {}': 'Documented',
      '@Deprecated("x")\nclass Annotated {}': 'Annotated',
      '/// Doc.\n@Deprecated("x")\nabstract class Both {}': 'Both',
      '@Deprecated("x")\nfinal class Modified {}': 'Modified',
    };

    for (final entry in decoratedCases.entries) {
      final label = entry.key.replaceAll('\n', ' ');
      test('reads the class name from "$label"', () {
        final node = _firstOfType<ClassDeclaration>(_parse(entry.key));

        expect(typeDeclarationName(node), equals(entry.value));
        expect(typeDeclarationNameToken(node)?.lexeme, equals(entry.value));
      });
    }

    const decoratedEnumCases = {
      '/// Doc.\nenum Documented { a }': 'Documented',
      '@Deprecated("x")\nenum Annotated { a }': 'Annotated',
    };

    for (final entry in decoratedEnumCases.entries) {
      final label = entry.key.replaceAll('\n', ' ');
      test('reads the enum name from "$label"', () {
        final node = _firstOfType<EnumDeclaration>(_parse(entry.key));

        expect(typeDeclarationName(node), equals(entry.value));
      });
    }

    test('returns a name token that points at the name, not the metadata', () {
      const source = '/// Doc.\n@Deprecated("x")\nclass Anchored {}';
      final node = _firstOfType<ClassDeclaration>(_parse(source));
      final token = typeDeclarationNameToken(node);

      expect(token, isNotNull);
      // Callers report on this token, so a doc comment or annotation must not
      // drag the reported location onto the wrong line.
      expect(token!.offset, equals(source.indexOf('Anchored')));
    });

    test('returns the name token itself, not just its lexeme', () {
      final node = _firstOfType<ClassDeclaration>(_parse('class Anchored {}'));
      final token = typeDeclarationNameToken(node);

      expect(token, isNotNull);
      // Callers report on this token, so its offset must point at the name
      // rather than at the `class` keyword.
      expect(token!.offset, equals('class '.length));
    });
  });

  group('typeDeclarationName agrees with the element model', () {
    // The typeDeclarationName cases above assert against hand-written
    // expectations, which cannot catch a structural reading that is wrong in a
    // way those cases do not happen to cover. This cross-checks the helper
    // against the analyzer's own answer, the declared fragment, which is
    // available on every row in the compatibility matrix. It mirrors the
    // isAbstractMethod cross-check and fails if a future analyzer reshapes the
    // declaration's children again.
    const fixturePath = 'test/src/utils/type_declaration_name_fixture.dart';
    const fixtureContent = '''
class Plain {}

abstract class Abstract {}

final class Modified<T> extends Plain implements Comparable<T> {
  Modified();

  int field = 0;

  void method() {}
}

sealed class Sealed {}

base class Based {}

class _Private {}

/// A documented class.
///
/// A doc comment and metadata are listed before the declaration's own children,
/// so a reading that takes the first child node lands on the comment or the
/// annotation instead of the name. Doc comments on public types are the norm,
/// which makes this the common case rather than an edge one.
class Documented {}

@Deprecated('annotated')
class Annotated {}

/// A documented and annotated class.
@Deprecated('both')
abstract class DocumentedAndAnnotated {}

enum Simple { a, b }

/// A documented enum.
enum DocumentedEnum { a, b }

@Deprecated('annotated')
enum AnnotatedEnum { a, b }

enum Configured<T> {
  first,
  second;

  const Configured();

  void describe() {}
}
''';

    late CompilationUnit unit;

    setUpAll(() async {
      final file = File(fixturePath)..writeAsStringSync(fixtureContent);
      try {
        unit = (await FileResolver.resolve(fixturePath)).unit;
      } finally {
        file.deleteSync();
      }
    });

    List<AstNode> typeDeclarations() {
      final found = <AstNode>[];
      _walk(unit, (node) {
        if (node is ClassDeclaration || node is EnumDeclaration) {
          found.add(node);
        }
      });

      return found;
    }

    String? fragmentName(AstNode node) => node is ClassDeclaration
        ? node.declaredFragment?.name
        : (node as EnumDeclaration).declaredFragment?.name;

    int? fragmentNameOffset(AstNode node) => node is ClassDeclaration
        ? node.declaredFragment?.nameOffset
        : (node as EnumDeclaration).declaredFragment?.nameOffset;

    test('finds every declaration in the fixture', () {
      // Guards the two tests below from passing vacuously if the walk stops
      // finding declarations on some analyzer row.
      expect(typeDeclarations(), hasLength(13));
    });

    test('matches the declared fragment name', () {
      for (final node in typeDeclarations()) {
        final oracle = fragmentName(node);

        expect(
          oracle,
          isNotNull,
          reason: 'fixture did not resolve for ${node.runtimeType}',
        );
        expect(
          typeDeclarationName(node),
          equals(oracle),
          reason: 'structural reading disagrees with the element model',
        );
      }
    });

    test('matches the declared fragment name offset', () {
      for (final node in typeDeclarations()) {
        final oracle = fragmentNameOffset(node);

        expect(oracle, isNotNull);
        // Rules report on this token, so a wrong offset would misplace the
        // diagnostic even when the lexeme happens to be right.
        expect(typeDeclarationNameToken(node)?.offset, equals(oracle));
      }
    });
  });

  group('classBodyMembers', () {
    test('collects members declared in the body', () {
      final node = _firstOfType<ClassDeclaration>(_parse('''
class Sample {
  int field = 0;
  Sample();
  void method() {}
  int get getter => 0;
}
'''));

      final members = classBodyMembers(node);

      expect(members, isNotNull);
      expect(members!.length, equals(4));
      expect(members.whereType<MethodDeclaration>().length, equals(2));
      expect(members.whereType<ConstructorDeclaration>().length, equals(1));
      expect(members.whereType<FieldDeclaration>().length, equals(1));
    });

    test('returns an empty list for an empty block body', () {
      final node = _firstOfType<ClassDeclaration>(_parse('class Empty {}'));

      expect(classBodyMembers(node), isEmpty);
    });

    test("does not reach into a member's own braces", () {
      final node = _firstOfType<ClassDeclaration>(
        _parse('class Outer { void m() { var x = 1; } }'),
      );

      // The method body also carries `{}`; only the class body must be read.
      expect(classBodyMembers(node)?.length, equals(1));
    });
  });

  group('enumConstants', () {
    test('collects the declared constants', () {
      final node = _firstOfType<EnumDeclaration>(
        _parse('enum Direction { north, south, east, west }'),
      );

      expect(
        enumConstants(node).map((constant) => constant.name.lexeme),
        equals(['north', 'south', 'east', 'west']),
      );
    });

    test('collects constants when the enum also declares members', () {
      final node = _firstOfType<EnumDeclaration>(_parse('''
enum Level {
  low,
  high;

  const Level();

  void describe() {}
}
'''));

      expect(
        enumConstants(node).map((constant) => constant.name.lexeme),
        equals(['low', 'high']),
      );
    });
  });

  group('enclosingTypeDeclaration', () {
    test('finds the class a method is declared in', () {
      final node = _firstOfType<MethodDeclaration>(
        _parse('class Host { void member() {} }'),
      );

      expect(enclosingTypeDeclaration(node), isA<ClassDeclaration>());
    });

    test('finds the class a constructor is declared in', () {
      final node = _firstOfType<ConstructorDeclaration>(
        _parse('class Host { factory Host() => Host._(); Host._(); }'),
      );

      expect(enclosingTypeDeclaration(node), isA<ClassDeclaration>());
    });

    test('finds the enclosing enum, mixin and extension', () {
      expect(
        enclosingTypeDeclaration(
          _firstOfType<MethodDeclaration>(_parse('enum E { a; void m() {} }')),
        ),
        isA<EnumDeclaration>(),
      );
      expect(
        enclosingTypeDeclaration(
          _firstOfType<MethodDeclaration>(_parse('mixin M { void m() {} }')),
        ),
        isA<MixinDeclaration>(),
      );
      expect(
        enclosingTypeDeclaration(
          _firstOfType<MethodDeclaration>(
            _parse('extension X on int { void m() {} }'),
          ),
        ),
        isA<ExtensionDeclaration>(),
      );
    });

    test('returns null for a top-level function', () {
      final node = _firstOfType<FunctionDeclaration>(_parse('void free() {}'));

      expect(enclosingTypeDeclaration(node), isNull);
    });

    test('stops at the nearest declaration', () {
      // A fixed parent.parent hop overshoots to the compilation unit when no
      // body node intervenes (analyzer 8.2-9.0); the walk must stop here.
      final method =
          _firstOfType<MethodDeclaration>(_parse('class Only { void m() {} }'));
      final enclosing = enclosingTypeDeclaration(method);

      expect(enclosing, isA<ClassDeclaration>());
      expect(typeDeclarationName(enclosing!), equals('Only'));
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

    test('returns the name of a documented extension type', () {
      final node = parseExtensionType(
        '/// Doc.\nextension type Meters(int value) {}',
      );

      expect(extensionTypeName(node), equals('Meters'));
    });

    test('returns the name of an annotated extension type', () {
      final node = parseExtensionType(
        '@Deprecated("x")\nextension type Meters(int value) {}',
      );

      expect(extensionTypeName(node), equals('Meters'));
    });

    test(
      'resolves the type name on both child shapes, never the representation '
      'field (validated per analyzer row)',
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
            reason: 'No first child node resolved for "${entry.key}". '
                'ExtensionTypeDeclaration child shape changed in this '
                'analyzer version.',
          );
          // Deliberately not asserting that the first child node *is* the name
          // part: on analyzer 8.2-9.0 the tree is flat and that node is the
          // representation, so such an assertion would pass vacuously there.
          // Every fixture names its representation field `value`, so requiring
          // the type name and rejecting `value` is what actually pins the
          // behaviour down on both shapes.
          expect(extensionTypeName(node), equals(entry.value));
          expect(
            extensionTypeName(node),
            isNot(equals('value')),
            reason: 'Read the representation field instead of the type name '
                'for "${entry.key}".',
          );
        }
      },
    );
  });
}
