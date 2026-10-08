import 'package:analyzer/dart/ast/ast.dart';

import '../../../utils/ast_compat.dart';
import 'class_type.dart';

/// Represents a declaration of a class / mixin / extension.
class ScopedClassDeclaration {
  /// The type of the declared class entity.
  final ClassType type;

  /// The node that represents a dart code snippet in the AST structure.
  final CompilationUnitMember declaration;

  /// Returns the user defined name.
  String get name {
    final node = declaration;
    String? name;

    if (node is ExtensionDeclaration) {
      name = node.name?.lexeme;
    } else if (node is ClassDeclaration) {
      name = typeDeclarationName(node);
    } else if (node is MixinDeclaration) {
      name = node.name.lexeme;
    } else if (node is EnumDeclaration) {
      name = typeDeclarationName(node);
    } else if (node is ExtensionTypeDeclaration) {
      name = extensionTypeName(node);
    }

    return name ?? '';
  }

  /// Initialize a newly created [ScopedClassDeclaration] with the given [type] and [declaration].
  const ScopedClassDeclaration(this.type, this.declaration);
}
