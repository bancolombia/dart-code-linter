// Cross-version helpers for analyzer 10.x–13.x. Analyzer 13 reshaped
// named-argument, record-field, default-parameter and label nodes; these
// helpers recognise the affected shapes structurally via `childEntities`.
// Later 13.x patches also deprecated some getters (e.g. `isAbstract`) whose
// replacements don't exist on earlier rows; those are reimplemented here from
// stable APIs so a single call site works across the whole supported range.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
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

/// Returns whether [node] declares an abstract method across analyzer versions.
///
/// `MethodDeclaration.isAbstract` is non-deprecated on analyzer 10.0–13.1, but
/// 13.2+ deprecates it in favour of `isComplete` — which is its inverse (not a
/// rename) and does not exist before 13.2. So neither getter is callable and
/// non-deprecated on every supported row. This mirrors the analyzer's own
/// `isAbstract` definition using stable APIs: a method is abstract iff it is
/// not external and its body is an empty (`;`) body with a real, non-synthetic
/// semicolon (the synthetic case is error recovery, not a real declaration).
bool isAbstractMethod(MethodDeclaration node) {
  final body = node.body;

  return node.externalKeyword == null &&
      body is EmptyFunctionBody &&
      !body.semicolon.isSynthetic;
}

/// Returns the declared type name of an [ExtensionTypeDeclaration] across
/// analyzer versions, or `null` if it can't be located.
///
/// `primaryConstructor.typeName` works on analyzer 10.0–13.0 but is deprecated
/// on 13.1+ (use `namePart.typeName`), which in turn is absent on 10.0–13.0 —
/// so neither getter is callable and non-deprecated on every supported row.
/// Instead the name is read structurally: on all rows the name part is the
/// first child node (preceded only by keyword tokens; `type` is a contextual
/// identifier and is not anchored on), and its first identifier token is the
/// type name (any leading `const` is a keyword token, so it is skipped).
String? extensionTypeName(ExtensionTypeDeclaration node) {
  final flat = _extensionTypeNameFromTokens(node);
  if (flat != null) {
    return flat;
  }

  final namePart = _firstChildNode(node);
  if (namePart == null) {
    return null;
  }

  return _firstIdentifierLexeme(namePart);
}

/// Reads the name from the flat child shape used by analyzer 8.2–9.0, where the
/// declaration's own tokens are `extension type <name> …` and the first child
/// node is the representation (`(int value)`), not the name part. Anchoring on
/// the contextual `type` identifier is safe here because the name is the next
/// identifier token after it; a leading `const` is a keyword token and is
/// skipped. Returns `null` on the nested rows (10.0+), where the name lives in
/// a child node and there is no second identifier token to find.
String? _extensionTypeNameFromTokens(ExtensionTypeDeclaration node) {
  var seenTypeToken = false;
  for (final entity in node.childEntities) {
    if (entity is! Token) {
      continue;
    }
    if (seenTypeToken && entity.type == TokenType.IDENTIFIER) {
      return entity.lexeme;
    }
    if (entity.lexeme == 'type') {
      seenTypeToken = true;
    }
  }

  return null;
}

/// Exposes the structurally-resolved name-part node of an
/// [ExtensionTypeDeclaration] so cross-version tests can validate the anchor's
/// shape against every analyzer row in the compatibility matrix.
@visibleForTesting
AstNode? debugExtensionTypeNamePart(ExtensionTypeDeclaration node) =>
    _firstChildNode(node);

AstNode? _firstChildNode(AstNode node) {
  // An `AnnotatedNode` lists its documentation comment and its metadata ahead
  // of its own children, so a declaration carrying either would otherwise
  // resolve to the comment or to the first annotation instead of to the node
  // the callers want. Neither carries an identifier token of its own (an
  // annotation's name is a nested node), so the reading did not land on a
  // wrong name, it produced none at all.
  final skipped = <AstNode>{};
  if (node is AnnotatedNode) {
    final comment = node.documentationComment;
    if (comment != null) {
      skipped.add(comment);
    }
    skipped.addAll(node.metadata);
  }

  for (final entity in node.childEntities) {
    if (entity is AstNode && !skipped.contains(entity)) {
      return entity;
    }
  }
  return null;
}

String? _firstIdentifierLexeme(AstNode node) =>
    _firstIdentifierToken(node)?.lexeme;

Token? _firstIdentifierToken(AstNode node) {
  for (final entity in node.childEntities) {
    if (entity is Token && entity.type == TokenType.IDENTIFIER) {
      return entity;
    }
  }
  return null;
}

/// Returns the [FormalParameterElement] that [expression] is bound to as a
/// call argument, across analyzer versions.
///
/// `Expression.correspondingParameter` alone only resolves positional
/// arguments on every row: for named arguments, analyzer 10–12 wrap the
/// expression in `NamedExpression` (an `Expression`, so the built-in getter
/// sees through it via its own parent-is-`ArgumentList` check), but analyzer
/// 13 wraps it in `NamedArgument` (an `Argument`, not an `Expression` — a type
/// that doesn't exist before 13), so the built-in getter returns `null`. This
/// falls back to a structural, name-based lookup against the enclosing call's
/// resolved parameters using the version-independent [asNamedArgument] view.
FormalParameterElement? correspondingParameterOf(Expression expression) {
  final direct = expression.correspondingParameter;
  if (direct != null) {
    return direct;
  }

  final named = asNamedArgument(expression.parent);
  if (named == null) {
    return null;
  }

  final argumentList = expression.parent?.parent;
  if (argumentList is! ArgumentList) {
    return null;
  }

  final parameters = _invocationParameters(argumentList.parent);
  for (final parameter in parameters) {
    if (parameter.name == named.name) {
      return parameter;
    }
  }

  return null;
}

List<FormalParameterElement> _invocationParameters(AstNode? invocation) {
  final element = switch (invocation) {
    MethodInvocation(:final methodName) =>
      methodName.element as ExecutableElement?,
    InstanceCreationExpression(:final constructorName) =>
      constructorName.element,
    _ => null,
  };

  return element?.formalParameters ?? const [];
}

const _typeDeclarationKeywords = {'class', 'enum'};

/// Returns the declared name token of a class or enum declaration across
/// analyzer versions, or `null` if it can't be located.
///
/// analyzer 8.2–8.3 expose the name directly, because `ClassDeclaration` and
/// `EnumDeclaration` implement `NamedCompilationUnitMember` there. analyzer
/// 8.4+ moved it behind `namePart.typeName` (nullable on 8.4, non-nullable
/// from 9.0) and dropped `NamedCompilationUnitMember` from both interfaces, so
/// neither `name` nor `namePart` is callable on every supported row. The token
/// is read structurally instead: on the older rows the name is the first
/// identifier token following the `class`/`enum` keyword (anchoring after the
/// keyword skips leading contextual identifiers such as `augment`), and on the
/// newer rows it is the first identifier token of the name-part child node.
Token? typeDeclarationNameToken(AstNode node) {
  final direct = _identifierAfterDeclarationKeyword(node);
  if (direct != null) {
    return direct;
  }

  final namePart = _firstChildNode(node);

  return namePart == null ? null : _firstIdentifierToken(namePart);
}

/// Returns the declared name of a class or enum declaration across analyzer
/// versions, or `null` if it can't be located. See [typeDeclarationNameToken].
String? typeDeclarationName(AstNode node) =>
    typeDeclarationNameToken(node)?.lexeme;

/// Returns the members declared in the block body of a class-like declaration,
/// or `null` when the declaration has no block body.
///
/// analyzer 8.2–8.3 hang members directly off the declaration
/// (`ClassDeclaration.members`); analyzer 8.4+ introduced a `ClassBody` child
/// (`BlockClassBody` for the `{ ... }` form, a type that doesn't exist on the
/// earlier rows) and dropped the direct `members` getter, so neither shape is
/// callable everywhere. The block body is recognised structurally by its `{`
/// token: on the older rows that token is a direct child of the declaration,
/// on the newer rows it belongs to the body node. Returning `null` mirrors the
/// `body is! BlockClassBody` guard callers used against the newer API.
List<ClassMember>? classBodyMembers(AstNode node) =>
    _blockBodyChildren<ClassMember>(node);

/// Returns the constants declared in an enum's block body across analyzer
/// versions, or an empty list when they can't be located.
///
/// Mirrors [classBodyMembers]: analyzer 8.2–8.3 hang the constants directly off
/// the declaration, analyzer 8.4+ moved them into an `EnumBody` child.
List<EnumConstantDeclaration> enumConstants(EnumDeclaration node) =>
    _blockBodyChildren<EnumConstantDeclaration>(node) ?? const [];

/// Collects the [T] children of [node]'s block body, looking first at [node]
/// itself (older rows, where the braces belong to the declaration) and then at
/// the child node owning the braces (newer rows). Returns `null` when no block
/// body is present.
List<T>? _blockBodyChildren<T extends AstNode>(AstNode node) {
  if (_hasBlockToken(node)) {
    return node.childEntities.whereType<T>().toList();
  }

  for (final entity in node.childEntities) {
    if (entity is AstNode && _hasBlockToken(entity)) {
      return entity.childEntities.whereType<T>().toList();
    }
  }

  return null;
}

bool _hasBlockToken(AstNode node) => node.childEntities.any(
      (entity) =>
          entity is Token && entity.type == TokenType.OPEN_CURLY_BRACKET,
    );

Token? _identifierAfterDeclarationKeyword(AstNode node) {
  var seenKeyword = false;
  for (final entity in node.childEntities) {
    if (entity is! Token) {
      continue;
    }
    if (seenKeyword && entity.type == TokenType.IDENTIFIER) {
      return entity;
    }
    if (_typeDeclarationKeywords.contains(entity.lexeme)) {
      seenKeyword = true;
    }
  }

  return null;
}

/// Returns the class-like declaration that [node] is declared in, across
/// analyzer versions, or `null` when there is none.
///
/// Members hang directly off the declaration on analyzer 8.2–9.0 and off an
/// intervening body node (`BlockClassBody`) from 10.0 onwards, so the fixed
/// `parent.parent` hop that is correct on the newer rows overshoots to the
/// compilation unit on the older ones. Walking ancestors is correct on both:
/// Dart has no nested class-like declarations, so the nearest enclosing one is
/// always the intended target.
AstNode? enclosingTypeDeclaration(AstNode node) {
  for (var current = node.parent; current != null; current = current.parent) {
    if (current is ClassDeclaration ||
        current is EnumDeclaration ||
        current is MixinDeclaration ||
        current is ExtensionDeclaration ||
        current is ExtensionTypeDeclaration) {
      return current;
    }
  }

  return null;
}
