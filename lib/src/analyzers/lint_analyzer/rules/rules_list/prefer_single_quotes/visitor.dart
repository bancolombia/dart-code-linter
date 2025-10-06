part of 'prefer_single_quotes_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _expressions = <Expression>[];

  Iterable<Expression> get expressions => _expressions;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    super.visitSimpleStringLiteral(node);

    if (node.isSingleQuoted) {
      return; // Already using single quotes
    }

    _expressions.add(node);
  }
}
