// Cross-version helpers for analyzer 10.x / 11.x / 12.x / 13.x.
//
// ## Why this file exists
//
// analyzer 13 reshaped several core AST nodes that this project's visitors
// rely on:
//
//   * `NamedExpression` was split into `NamedArgument` (in `ArgumentList`)
//     and `RecordLiteralNamedField` (in `RecordLiteral`). Both expose the
//     argument's name and inner expression, but they are no longer
//     `Expression` subclasses.
//   * `ArgumentList.arguments` now returns `NodeList<Argument>` instead of
//     `NodeList<Expression>`. Positional args still satisfy `Expression`
//     because `Expression` implements `Argument` in 13, but named args do
//     not.
//   * `DefaultFormalParameter` was removed; default values are now exposed
//     compositionally as `FormalParameter.defaultClause?.expression`.
//   * `Label` now uses a `Token name` instead of `SimpleIdentifier label`
//     (used by `LabeledStatement`, `BreakStatement`, `ContinueStatement`).
//
// The helpers below recognise the affected node shapes structurally via
// `childEntities`, so the codebase compiles cleanly against 10–13 without
// referencing any version-specific type.
//
// ## When to use which helper
//
// In a visitor that walks `ArgumentList.arguments`:
//
//   * If you need both the argument name AND the expression (e.g. to match
//     by parameter name), keep the loop variable typed as `AstNode` and
//     call [asNamedArgument] / [isNamedArgument] / [unwrapArgumentExpression].
//   * If you only need the Expression for `staticType` / element checks,
//     prefer [argumentExpressions], which yields `Iterable<Expression>`
//     directly with named args unwrapped.
//
// Both patterns are intentional and appear in the codebase. Don't try to
// unify them — `argumentExpressions` discards the named-arg name on
// purpose; if you need the name, you must keep the original node.
//
// ## Migration recipe
//
// Old code (analyzer 10–12):
//
//   for (final arg in argumentList.arguments) {
//     if (arg is NamedExpression && arg.name.label.name == 'foo') {
//       final expr = arg.expression;
//       ...
//     }
//   }
//
// Version-agnostic equivalent:
//
//   for (final arg in argumentList.arguments) {
//     final named = asNamedArgument(arg);
//     if (named != null && named.name == 'foo') {
//       final expr = named.expression;
//       ...
//     }
//   }
//
// For `DefaultFormalParameter`:
//
//   if (parameter is DefaultFormalParameter && parameter.defaultValue != null)
//
// becomes:
//
//   if (defaultParameterValue(parameter) != null)

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';

/// A view of a named-argument-like node (`name: expression`).
///
/// `name` is the bare identifier text (the part before `:`), already
/// stringified so callers do not need to depend on `Label` directly — that
/// type's internal shape differs between analyzer 10–12 and 13.
typedef NamedArgumentView = ({String name, Expression expression});

/// Runtime type names that represent named-argument-shaped nodes across
/// analyzer versions. Used as a defence-in-depth check on top of the
/// structural shape recognition in [asNamedArgument] so a future analyzer
/// release introducing a new node with a similar child layout can't be
/// silently misclassified.
const _namedArgumentRuntimeTypes = {
  'NamedExpressionImpl', // analyzer 10–12
  'NamedExpression',
  'NamedArgumentImpl', // analyzer 13 (in ArgumentList)
  'NamedArgument',
  'RecordLiteralNamedFieldImpl', // analyzer 13 (in RecordLiteral)
  'RecordLiteralNamedField',
};

/// Returns a view of [node] if it is a named-argument-shaped node, otherwise
/// `null`.
///
/// Recognized shapes:
///   * analyzer 10–12 (`NamedExpression`): children `[Label, Expression]`.
///   * analyzer 13 (`NamedArgument`, `RecordLiteralNamedField`): children
///     `[Token name, Token ':', Expression]`.
///
/// As a defence-in-depth check, the runtime type name of [node] must match
/// one of [_namedArgumentRuntimeTypes] — this prevents an unrelated future
/// AST node that happens to share one of these shapes from being silently
/// recognised as a named argument.
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

/// Whether [node] is a named-argument-shaped node.
bool isNamedArgument(Object? node) => asNamedArgument(node) != null;

/// Returns `node.expression` for a named-argument node, otherwise [node]
/// itself when it is already an [Expression]. Useful for accessing
/// `staticType` or element information on an argument-list entry without
/// caring whether the entry is positional or named.
Expression? unwrapArgumentExpression(Object? node) {
  final named = asNamedArgument(node);
  if (named != null) {
    return named.expression;
  }
  return node is Expression ? node : null;
}

/// Adapts `argumentList.arguments` to `Iterable<Expression>` across analyzer
/// versions. Named arguments are unwrapped to their `.expression`. Note that
/// the named-argument name is discarded; use [asNamedArgument] directly if
/// you need to identify arguments by name.
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
///   * analyzer 10–12: `DefaultFormalParameter` holds children
///     `[NormalFormalParameter, Token '=', Expression]` when a default
///     exists.
///   * analyzer 13: `FormalParameter` exposes a `defaultClause` child whose
///     own children are `[Token '=', Expression]`.
///
/// The helper anchors on the `=` token in both layouts and returns the
/// Expression that immediately follows it. Anchoring on `=` is what
/// distinguishes a default value from incidental Expression-typed nodes
/// elsewhere under the parameter (e.g. an identifier nested inside a
/// `NamedType`, which is itself an `Expression` subtype in analyzer 10–12).
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
