// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/replacement.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class PreferEnumsByNameRule extends DartRule {
  static const ruleId = 'prefer-enums-by-name';
  static const _warningMessage = 'Prefer using values.byName';
  static const _fixComment = 'Convert to values.byName().';

  PreferEnumsByNameRule([Map<String, Object> config = const {}])
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.style),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor();

    source.unit.visitChildren(visitor);

    return visitor.invocations.map((invocation) {
      final replacement = _byNameReplacement(invocation, source);

      return createIssue(
        rule: this,
        location: nodeLocation(
          node: invocation,
          source: source,
          withCommentOrMetadata: false,
        ),
        message: _warningMessage,
        replacements: replacement == null
            ? null
            : [Replacement(comment: _fixComment, replacement: replacement)],
      );
    }).toList(growable: false);
  }
}

/// Builds a `values.byName(...)` replacement for a flagged `firstWhere`
/// invocation, or returns `null` when the call is not safely convertible.
///
/// Only the exact `firstWhere((e) => e.name == x)` shape (operands either way
/// round, no `orElse`, lookup `x` not referencing the closure parameter) is
/// convertible; `byName(x)` would otherwise change behavior or not compile.
String? _byNameReplacement(
  MethodInvocation node,
  InternalResolvedUnitResult source,
) {
  final target = node.target;
  if (target == null) {
    return null;
  }

  // A sole positional closure argument: a second (named `orElse`) argument
  // has no `byName` equivalent, and its presence makes this != 1.
  final arguments = node.argumentList.arguments;
  if (arguments.length != 1) {
    return null;
  }

  final closure = arguments.first;
  if (closure is! FunctionExpression) {
    return null;
  }

  final parameters = closure.parameters?.parameters;
  if (parameters == null || parameters.length != 1) {
    return null;
  }
  final parameterName = parameters.first.name?.lexeme;
  if (parameterName == null) {
    return null;
  }

  final body = closure.body;
  if (body is! ExpressionFunctionBody) {
    return null;
  }

  final expression = body.expression;
  if (expression is! BinaryExpression ||
      expression.operator.type != TokenType.EQ_EQ) {
    return null;
  }

  final left = expression.leftOperand;
  final right = expression.rightOperand;

  final Expression lookup;
  if (_isNameAccess(left, parameterName) &&
      !_isNameAccess(right, parameterName)) {
    lookup = right;
  } else if (_isNameAccess(right, parameterName) &&
      !_isNameAccess(left, parameterName)) {
    lookup = left;
  } else {
    return null;
  }

  // The lookup expression survives outside the closure, so it must not depend
  // on the (now removed) closure parameter.
  if (_referencesIdentifier(lookup, parameterName)) {
    return null;
  }

  final targetSource = source.content.substring(target.offset, target.end);
  final lookupSource = source.content.substring(lookup.offset, lookup.end);

  return '$targetSource.byName($lookupSource)';
}

/// Whether [expression] is `<parameterName>.name`.
bool _isNameAccess(Expression expression, String parameterName) {
  if (expression is PrefixedIdentifier) {
    return expression.prefix.name == parameterName &&
        expression.identifier.name == 'name';
  }
  if (expression is PropertyAccess) {
    final target = expression.target;

    return target is SimpleIdentifier &&
        target.name == parameterName &&
        expression.propertyName.name == 'name';
  }

  return false;
}

bool _referencesIdentifier(AstNode node, String name) {
  final finder = _IdentifierFinder(name);
  node.accept(finder);

  return finder.found;
}

class _IdentifierFinder extends RecursiveAstVisitor<void> {
  _IdentifierFinder(this._name);

  final String _name;
  bool found = false;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == _name) {
      found = true;
    }
    super.visitSimpleIdentifier(node);
  }
}
