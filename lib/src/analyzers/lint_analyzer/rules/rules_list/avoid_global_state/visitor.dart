part of 'avoid_global_state_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _declarations = <AstNode>[];

  Iterable<AstNode> get declarations => _declarations;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);

    final element = node.declaredFragment?.element;

    if (element is LibraryFragment) {
      if (_isNodeValid(node)) {
        _declarations.add(node);
      }
    } else if ((element?.isStatic ?? false) && _isNodeValid(node)) {
      _declarations.add(node);
    }
  }

  bool _isNodeValid(VariableDeclaration node) =>
      !node.isFinal &&
      !node.isConst &&
      !(node.declaredFragment?.element.isPrivate ?? false);
}
