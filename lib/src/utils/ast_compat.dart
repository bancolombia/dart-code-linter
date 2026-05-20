// Cross-version helpers for analyzer 10.x / 11.x / 12.x / 13.x.
//
// analyzer 13 reshaped the argument and parameter AST:
//   * `NamedExpression` was split into `NamedArgument` (in `ArgumentList`)
//     and `RecordLiteralNamedField` (in `RecordLiteral`). Both expose the
//     argument's `name` (Token in 13) and the wrapped expression, but they
//     are no longer `Expression` subclasses.
//   * `ArgumentList.arguments` now returns `NodeList<Argument>` instead of
//     `NodeList<Expression>` (positional args still satisfy `Expression`
//     because `Expression` implements `Argument` in 13).
//   * `DefaultFormalParameter` was removed; default values are now exposed
//     compositionally as `FormalParameter.defaultClause?.expression`.
//   * `Label` now uses a `Token name` instead of `SimpleIdentifier label`
//     (used by `LabeledStatement`, `BreakStatement`, `ContinueStatement`).
//
// The helpers below recognise named-argument-shaped nodes structurally via
// `childEntities`, supporting both AST layouts. The exposed name is
// stringified so callers do not need to depend on `Label` at all.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// A view of a named-argument-like node (`name: expression`).
typedef NamedArgumentView = ({String name, Expression expression});

/// Returns a view of [node] if it is a named-argument-shaped node, otherwise
/// `null`.
///
/// Recognizes:
///   * analyzer 10–12: `NamedExpression` — children `[Label, Expression]`.
///   * analyzer 13:    `NamedArgument` / `RecordLiteralNamedField` — children
///     `[Token name, Token ':', Expression]`.
NamedArgumentView? asNamedArgument(Object? node) {
  if (node is! AstNode) {
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

/// Whether [node] is a named-argument-shaped node.
bool isNamedArgument(Object? node) => asNamedArgument(node) != null;

/// Returns `node.expression` for a named-argument node, otherwise [node]
/// itself when it is already an [Expression].
Expression? unwrapArgumentExpression(Object? node) {
  final named = asNamedArgument(node);
  if (named != null) {
    return named.expression;
  }
  return node is Expression ? node : null;
}

/// Adapts `argumentList.arguments` to `Iterable<Expression>` across analyzer
/// versions. Named arguments are unwrapped to their `.expression`.
Iterable<Expression> argumentExpressions(ArgumentList list) sync* {
  for (final arg in list.arguments) {
    final expr = unwrapArgumentExpression(arg);
    if (expr != null) {
      yield expr;
    }
  }
}

/// Returns the identifier text of a [Label] regardless of analyzer version.
///
///   * analyzer 10–12: `label.label.name` (SimpleIdentifier child).
///   * analyzer 13:    `label.name.lexeme` (Token child).
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
///   * analyzer 10–12: `DefaultFormalParameter.defaultValue`
///   * analyzer 13:    `FormalParameter.defaultClause?.expression`
Expression? defaultParameterValue(FormalParameter parameter) {
  for (final entity in parameter.childEntities) {
    if (entity is Expression) {
      return entity;
    }
    if (entity is AstNode && entity is! Expression) {
      for (final sub in entity.childEntities) {
        if (sub is Expression) {
          return sub;
        }
      }
    }
  }
  return null;
}
