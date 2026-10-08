part of 'prefer_single_widget_per_file_rule.dart';

class _Visitor extends SimpleAstVisitor<void> {
  final bool _ignorePrivateWidgets;

  final _nodes = <ClassDeclaration>[];

  _Visitor({required bool ignorePrivateWidgets})
      : _ignorePrivateWidgets = ignorePrivateWidgets;

  Iterable<ClassDeclaration> get nodes =>
      _nodes.length > 1 ? _nodes.skip(1) : [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    final classType = node.extendsClause?.superclass.type;
    if (!isWidgetOrSubclass(classType)) {
      return;
    }

    if (_ignorePrivateWidgets) {
      // An unresolvable name is skipped rather than guessed at: reporting a
      // widget as public when its name could not be read would be a false
      // positive under this option.
      final name = typeDeclarationName(node);
      if (name == null || Identifier.isPrivateName(name)) {
        return;
      }
    }

    _nodes.add(node);
  }
}
