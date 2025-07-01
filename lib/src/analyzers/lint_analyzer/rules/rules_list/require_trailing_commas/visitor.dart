// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// Source: https://github.com/dart-lang/sdk/blob/main/pkg/linter/lib/src/rules/require_trailing_commas.dart

part of 'require_trailing_commas_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final LineInfo _lineInfo;
  final int _minParameters;

  final _nodes = <AstNode>[];

  Iterable<AstNode> get nodes => _nodes;

  _Visitor(this._lineInfo, this._minParameters);

  @override
  void visitArgumentList(ArgumentList node) {
    super.visitArgumentList(node);
    if (node.arguments.isEmpty) return;
    if (node.arguments.length <= _minParameters) return;
    _checkTrailingComma(
      openingToken: node.leftParenthesis,
      closingToken: node.rightParenthesis,
      lastNode: node.arguments.last,
    );
  }

  @override
  void visitAssertInitializer(AssertInitializer node) {
    super.visitAssertInitializer(node);
    _checkTrailingComma(
      openingToken: node.leftParenthesis,
      closingToken: node.rightParenthesis,
      lastNode: node.message ?? node.condition,
    );
  }

  @override
  void visitAssertStatement(AssertStatement node) {
    super.visitAssertStatement(node);
    _checkTrailingComma(
      openingToken: node.leftParenthesis,
      closingToken: node.rightParenthesis,
      lastNode: node.message ?? node.condition,
    );
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    super.visitFormalParameterList(node);
    if (node.parameters.isEmpty) return;
    _checkTrailingComma(
      openingToken: node.leftParenthesis,
      closingToken: node.rightParenthesis,
      lastNode: node.parameters.last,
      errorToken: node.rightDelimiter ?? node.rightParenthesis,
    );
  }

  @override
  void visitListLiteral(ListLiteral node) {
    super.visitListLiteral(node);
    if (node.elements.isNotEmpty) {
      _checkTrailingComma(
        openingToken: node.leftBracket,
        closingToken: node.rightBracket,
        lastNode: node.elements.last,
      );
    }
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    super.visitSetOrMapLiteral(node);
    if (node.elements.isNotEmpty) {
      _checkTrailingComma(
        openingToken: node.leftBracket,
        closingToken: node.rightBracket,
        lastNode: node.elements.last,
      );
    }
  }

  void _checkTrailingComma({
    required Token openingToken,
    required Token closingToken,
    required AstNode lastNode,
    Token? errorToken,
  }) {
    errorToken ??= closingToken;

    // Early exit if trailing comma is present.
    if (lastNode.endToken.next?.type == TokenType.COMMA) return;

    // No trailing comma is needed if the function call or declaration, up to
    // the closing parenthesis, fits on a single line. Ensuring the left and
    // right parenthesis are on the same line is sufficient since `dart format`
    // places the left parenthesis right after the identifier (on the same
    // line).
    if (_isSameLine(openingToken, closingToken)) return;

    // Check the last parameter to determine if there are any exceptions.
    if (_shouldAllowTrailingCommaException(lastNode)) return;

    _nodes.add(lastNode);
  }

  bool _isSameLine(Token token1, Token token2) =>
      _lineInfo.getLocation(token1.offset).lineNumber ==
      _lineInfo.getLocation(token2.end).lineNumber;

  bool _shouldAllowTrailingCommaException(AstNode lastNode) {
    // No exceptions are allowed if the last argument is named.
    if (lastNode is FormalParameter && lastNode.isNamed) return false;

    // No exceptions are allowed if the entire last argument fits on one line.
    if (_isSameLine(lastNode.beginToken, lastNode.endToken)) return false;

    // Exception is allowed if the last argument is a function literal.
    if (lastNode is FunctionExpression && lastNode.body is BlockFunctionBody) {
      return true;
    }

    // Exception is allowed if the last argument is a (multiline) string
    // literal.
    if (lastNode is StringLiteral) return true;

    // Exception is allowed if the last argument is a anonymous function call.
    // This case arises a lot in asserts.
    if (lastNode is FunctionExpressionInvocation &&
        lastNode.function is FunctionExpression &&
        _isSameLine(
          lastNode.argumentList.leftParenthesis,
          lastNode.argumentList.rightParenthesis,
        )) {
      return true;
    }

    // Exception is allowed if the last argument is a set, map or list literal.
    if (lastNode is SetOrMapLiteral || lastNode is ListLiteral) return true;

    return false;
  }
}
