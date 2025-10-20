part of 'avoid_dynamic_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitNamedType(NamedType node) {
    if ((node.type is DynamicType) && node.name2.toString() == 'dynamic') {
      if (node is ExtensionDeclaration) {
        return;
      }
      final grandParent = node.parent?.parent;
      final parent = node.parent;

      if (grandParent != null &&
          parent != null &&
          !_isWithinMap(grandParent) &&
          !_isWithinMap(parent)) {
        _nodes.add(node.parent ?? node);
      }
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.extendsClause != null) {
      final baseType = node.extendsClause?.superclass;
      if (baseType is Identifier && baseType?.name2.toString() == 'dynamic') {
        _nodes.add(node);
      } else {
        baseType?.typeArguments?.arguments.forEach((type) {
          if (type is NamedType && type.name2.toString() == 'dynamic') {
            _nodes.add(type.parent ?? type);
          }
        });
      }
    }
    super.visitClassDeclaration(node);
  }

  bool _isWithinMap(AstNode grandParent) {
    final grandGrandParent = grandParent.parent;

    return grandGrandParent is NamedType &&
            (grandGrandParent.type?.isDartCoreMap ?? false) ||
        grandGrandParent is SetOrMapLiteral && grandGrandParent.isMap;
  }
}
