// Cross-version helpers for analyzer 10.x–13.x. Analyzer 13 reshaped
// named-argument, record-field, default-parameter and label nodes; these
// helpers recognise the affected shapes structurally via `childEntities`.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:meta/meta.dart';

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

@visibleForTesting
Set<String> get debugNamedArgumentRuntimeTypes => _namedArgumentRuntimeTypes;

@visibleForTesting
bool debugMatchesNamedArgumentShape(AstNode node) =>
    _matchesNamedArgumentShape(node.childEntities.toList());

bool _matchesNamedArgumentShape(List<SyntacticEntity> children) {
  if (children.isEmpty) {
    return false;
  }

  // analyzer 13: identifier token + colon token + expression.
  if (children.length >= 3 &&
      children[0] is Token &&
      (children[0] as Token).type == TokenType.IDENTIFIER &&
      children[1] is Token &&
      (children[1] as Token).type == TokenType.COLON &&
      children.last is Expression) {
    return true;
  }

  // analyzer 10–12: Label child followed by Expression child.
  if (children.length >= 2 &&
      children.first is Label &&
      children.last is Expression) {
    return true;
  }

  return false;
}

/// Returns a view of [node] if it is a named-argument-shaped node, else `null`.
NamedArgumentView? asNamedArgument(Object? node) {
  if (node is! AstNode) {
    return null;
  }
  if (!_namedArgumentRuntimeTypes.contains(node.runtimeType.toString())) {
    return null;
  }

  final children = node.childEntities.toList();
  if (!_matchesNamedArgumentShape(children)) {
    return null;
  }

  if (children[0] is Token) {
    return (
      name: (children[0] as Token).lexeme,
      expression: children.last as Expression,
    );
  }

  return (
    name: labelName(children.first as Label),
    expression: children.last as Expression,
  );
}

bool isNamedArgument(Object? node) => asNamedArgument(node) != null;

/// Returns the inner expression of a named-argument node, [node] itself if it
/// is already an [Expression], otherwise `null`.
Expression? unwrapArgumentExpression(Object? node) {
  final named = asNamedArgument(node);
  if (named != null) {
    return named.expression;
  }
  return node is Expression ? node : null;
}

/// Adapts `argumentList.arguments` to `Iterable<Expression>` across analyzer
/// versions, unwrapping named arguments and discarding their names.
Iterable<Expression> argumentExpressions(ArgumentList list) sync* {
  for (final arg in list.arguments) {
    final expr = unwrapArgumentExpression(arg);
    if (expr != null) {
      yield expr;
    }
  }
}

/// Returns the identifier text of a [Label] regardless of analyzer version.
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

/// Returns the default value expression of a formal parameter across analyzer
/// versions. Anchors on `=` to avoid matching incidental Expression subtypes
/// elsewhere under the parameter (e.g. `NamedType` in 10–12).
Expression? defaultParameterValue(FormalParameter parameter) {
  final direct = _expressionAfterEqualsToken(parameter.childEntities);
  if (direct != null) {
    return direct;
  }

  // analyzer 13: `=` sits inside a `defaultClause` child.
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
