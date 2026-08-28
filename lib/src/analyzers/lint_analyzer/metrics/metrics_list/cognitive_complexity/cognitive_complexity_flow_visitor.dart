// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// A single occurrence collected by [CognitiveComplexityFlowVisitor] together
/// with the score it contributes and a human readable description.
class CognitiveComplexityEntity {
  final SyntacticEntity entity;
  final int score;
  final String description;

  const CognitiveComplexityEntity({
    required this.entity,
    required this.score,
    required this.description,
  });
}

/// The AST visitor that computes the cognitive complexity of a function body
/// following SonarSource's Cognitive Complexity algorithm: every branching
/// structure adds a base increment (B1), and structures that are nested
/// inside other branching structures add an extra increment per level of
/// nesting (B2).
class CognitiveComplexityFlowVisitor extends RecursiveAstVisitor<void> {
  final AstNode _root;
  final String? _functionName;

  int _nestingLevel = 0;

  final _scoredEntities = <CognitiveComplexityEntity>[];

  /// Returns the collected entities that increase cognitive complexity together with their score.
  Iterable<CognitiveComplexityEntity> get scoredEntities => _scoredEntities;

  /// Returns the total cognitive complexity score.
  int get complexity =>
      _scoredEntities.fold(0, (sum, entity) => sum + entity.score);

  /// Initialize a newly created [CognitiveComplexityFlowVisitor] for the
  /// function or method represented by [root], optionally checking calls to
  /// [functionName] for recursion.
  CognitiveComplexityFlowVisitor({
    required AstNode root,
    String? functionName,
  })  : _root = root,
        _functionName = functionName;

  @override
  void visitIfStatement(IfStatement node) {
    final parent = node.parent;
    final isElseIf = parent is IfStatement && parent.elseStatement == node;

    if (isElseIf) {
      _addScore(node.ifKeyword, 1, 'Else if statement');
    } else {
      _addNestingScore(node.ifKeyword, 'If statement');
    }

    node.expression.accept(this);
    _nested(() => node.thenStatement.accept(this));

    final elseStatement = node.elseStatement;
    if (elseStatement is IfStatement) {
      elseStatement.accept(this);
    } else if (elseStatement != null) {
      final elseKeyword = node.elseKeyword;
      if (elseKeyword != null) {
        _addScore(elseKeyword, 1, 'Else statement');
      }
      _nested(() => elseStatement.accept(this));
    }
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _addNestingScore(node.question, 'Conditional expression');

    node.condition.accept(this);
    _nested(() => node.thenExpression.accept(this));
    _nested(() => node.elseExpression.accept(this));
  }

  @override
  void visitForStatement(ForStatement node) {
    _addNestingScore(node.forKeyword, 'For statement');

    node.forLoopParts.accept(this);
    _nested(() => node.body.accept(this));
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _addNestingScore(node.whileKeyword, 'While statement');

    node.condition.accept(this);
    _nested(() => node.body.accept(this));
  }

  @override
  void visitDoStatement(DoStatement node) {
    _addNestingScore(node.doKeyword, 'Do statement');

    _nested(() => node.body.accept(this));
    node.condition.accept(this);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _addNestingScore(node.switchKeyword, 'Switch statement');

    node.expression.accept(this);
    _nested(() {
      for (final member in node.members) {
        member.accept(this);
      }
    });
  }

  @override
  void visitCatchClause(CatchClause node) {
    _addNestingScore(
      node.catchKeyword ?? node.onKeyword ?? node.beginToken,
      'Catch clause',
    );

    _nested(() => node.body.accept(this));
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    final root = _root;
    final isRootFunction =
        root is FunctionDeclaration && root.functionExpression == node;

    if (isRootFunction) {
      super.visitFunctionExpression(node);
    } else {
      _nested(() => super.visitFunctionExpression(node));
    }
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    if (node.label != null) {
      _addScore(node.breakKeyword, 1, 'Labeled break statement');
    }

    super.visitBreakStatement(node);
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    if (node.label != null) {
      _addScore(node.continueKeyword, 1, 'Labeled continue statement');
    }

    super.visitContinueStatement(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operatorType = node.operator.type;

    if (_isLogicalOperator(operatorType)) {
      final parent = node.parent;
      final isSameOperatorRun =
          parent is BinaryExpression && parent.operator.type == operatorType;

      if (!isSameOperatorRun) {
        _addScore(node.operator, 1, 'Operator ${node.operator.lexeme}');
      }
    }

    super.visitBinaryExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_functionName != null &&
        node.target == null &&
        node.methodName.name == _functionName) {
      _addScore(node.methodName, 1, 'Recursive call');
    }

    super.visitMethodInvocation(node);
  }

  bool _isLogicalOperator(TokenType type) =>
      type == TokenType.AMPERSAND_AMPERSAND || type == TokenType.BAR_BAR;

  void _nested(void Function() action) {
    _nestingLevel++;
    action();
    _nestingLevel--;
  }

  void _addNestingScore(SyntacticEntity entity, String description) {
    _addScore(entity, 1 + _nestingLevel, description);
  }

  void _addScore(SyntacticEntity entity, int score, String description) {
    _scoredEntities.add(
      CognitiveComplexityEntity(
        entity: entity,
        score: score,
        description: description,
      ),
    );
  }
}
