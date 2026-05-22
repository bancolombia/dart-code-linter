// Cross-version helpers for analyzer 10.x–13.x. Analyzer 13 reshaped
// named-argument, record-field, default-parameter and label nodes; these
// helpers recognise the affected shapes structurally via `childEntities`.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';

/// A view of a named-argument-like node (`name: expression`).
typedef NamedArgumentView = ({String name, Expression expression});

const _namedArgumentRuntimeTypes = {
  'NamedExpressionImpl', // analyzer 10–12
  'NamedExpression',
  'NamedArgumentImpl', // analyzer 13 (in ArgumentList)
  'NamedArgument',
  'RecordLiteralNamedFieldImpl', // analyzer 13 (in RecordLiteral)
  'RecordLiteralNamedField',
};

/// Returns a view of [node] if it is a named-argument-shaped node, else `null`.
///
///   * analyzer 10–12 (`NamedExpression`): children `[Label, Expression]`.
///   * analyzer 13 (`NamedArgument`, `RecordLiteralNamedField`): children
///     `[Token name, Token ':', Expression]`.
NamedArgumentView? asNamedArgument(Object? node) {
  if (node is! AstNode) {
    return null;
  }
  if (!_namedArgumentRuntimeTypes.contains(node.runtimeType.toString())) {
    return null;
  }

  final children = node.childEntities.toList();
  if (children.isEmpty) {
    return null;
  }

  // analyzer 13 shape: identifier token + colon token + expression.
  if (children.length >= 3 &&
      children[0] is Token &&
      (children[0] as Token).type == TokenType.IDENTIFIER &&
      children[1] is Token &&
      (children[1] as Token).type == TokenType.COLON &&
      children.last is Expression) {
    return (
      name: (children[0] as Token).lexeme,
      expression: children.last as Expression,
    );
  }

  // analyzer 10–12 shape: Label child followed by Expression child.
  if (children.length >= 2 &&
      children.first is Label &&
      children.last is Expression) {
    return (
      name: labelName(children.first as Label),
      expression: children.last as Expression,
    );
  }

  return null;
}

bool isNamedArgument(Object? node) => asNamedArgument(node) != null;

/// Returns the inner expression of a named-argument node, otherwise [node]
/// itself if it is already an [Expression], otherwise `null`.
Expression? unwrapArgumentExpression(Object? node) {
  final named = asNamedArgument(node);
  if (named != null) {
    return named.expression;
  }
  return node is Expression ? node : null;
}

/// Adapts `argumentList.arguments` to `Iterable<Expression>` across analyzer
/// versions, unwrapping named arguments. The named-argument name is discarded;
/// use [asNamedArgument] directly if you need it.
Iterable<Expression> argumentExpressions(ArgumentList list) sync* {
  for (final arg in list.arguments) {
    final expr = unwrapArgumentExpression(arg);
    if (expr != null) {
      yield expr;
    }
  }
}

/// Returns the identifier text of a [Label] regardless of analyzer version
/// (`SimpleIdentifier` child in 10–12, `Token` child in 13).
String labelName(Label label) {
  for (final entity in label.childEntities) {
    if (entity is SimpleIdentifier) {
      return entity.name;
    }
    if (entity is Token && entity.type == TokenType.IDENTIFIER) {
      return entity.lexeme;
    }
  }
  return '';
}

/// Returns the default value expression of a formal parameter, regardless of
/// the analyzer version's parameter representation.
///
///   * analyzer 10–12: `DefaultFormalParameter` holds children
///     `[NormalFormalParameter, Token '=', Expression]` when a default exists.
///   * analyzer 13: `FormalParameter` exposes a `defaultClause` child whose
///     children are `[Token '=', Expression]`.
///
/// Anchors on `=` in both layouts to avoid matching incidental Expression
/// subtypes elsewhere under the parameter (e.g. `NamedType` in 10–12).
Expression? defaultParameterValue(FormalParameter parameter) {
  // analyzer 10–12: `=` and its Expression sit directly under the parameter.
  final direct = _expressionAfterEqualsToken(parameter.childEntities);
  if (direct != null) {
    return direct;
  }

  // analyzer 13: walk the immediate non-Expression AstNode children looking
  // for a `defaultClause`-shaped subtree (`= <Expression>`).
  for (final child in parameter.childEntities) {
    if (child is! AstNode || child is Expression) {
      continue;
    }
    final nested = _expressionAfterEqualsToken(child.childEntities);
    if (nested != null) {
      return nested;
    }
  }

  return null;
}

Expression? _expressionAfterEqualsToken(Iterable<SyntacticEntity> entities) {
  final list = entities.toList();
  for (var i = 0; i < list.length - 1; i++) {
    final entity = list[i];
    if (entity is Token && entity.type == TokenType.EQ) {
      final next = list[i + 1];
      if (next is Expression) {
        return next;
      }
    }
  }
  return null;
}
