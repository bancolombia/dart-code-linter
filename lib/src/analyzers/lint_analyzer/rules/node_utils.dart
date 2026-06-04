import 'package:analyzer/dart/ast/ast.dart';

String humanReadableNodeType(AstNode? node) {
  if (node is ClassDeclaration) {
    return 'Class';
  } else if (node is EnumDeclaration) {
    return 'Enum';
  } else if (node is ExtensionDeclaration) {
    return 'Extension';
  } else if (node is MixinDeclaration) {
    return 'Mixin';
  } else if (node is TypeAlias) {
    return 'Type alias';
  }

  return 'Node';
}
