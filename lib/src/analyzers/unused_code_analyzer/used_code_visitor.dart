// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';

import '../../utils/flutter_types_utils.dart';
import 'models/file_elements_usage.dart';

// Copied from https://github.com/dart-lang/sdk/blob/main/pkg/analyzer/lib/src/error/imports_verifier.dart#L15

class UsedCodeVisitor extends RecursiveAstVisitor<void> {
  final fileElementsUsage = FileElementsUsage();

  UsedCodeVisitor();

  @override
  void visitImportDirective(ImportDirective node) {
    if (node.configurations.isNotEmpty) {
      final paths = node.configurations.map((config) {
        final uri = config.resolvedUri;

        return (uri is DirectiveUriWithSource) ? uri.source.fullName : null;
      }).whereNotNull();
      final mainImport = node.element?.importedLibrary?.source.fullName;

      final allPaths = {if (mainImport != null) mainImport, ...paths};

      fileElementsUsage.conditionalElements.update(
        allPaths,
        (conditionalElements) => conditionalElements,
        ifAbsent: () => {},
      );
    }

    super.visitImportDirective(node);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    super.visitExportDirective(node);

    final path = node.element?.exportedLibrary?.source.fullName;
    if (path != null) {
      fileElementsUsage.exports.add(path);
    }
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _recordAssignmentTarget(node, node.leftHandSide);

    super.visitAssignmentExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _recordIfExtensionMember(node.staticElement);

    super.visitBinaryExpression(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _recordIfExtensionMember(node.staticElement);

    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    _recordIfExtensionMember(node.staticElement);

    super.visitIndexExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _recordAssignmentTarget(node, node.operand);

    super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _recordAssignmentTarget(node, node.operand);
    _recordIfExtensionMember(node.staticElement);

    super.visitPrefixExpression(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _visitIdentifier(node, node.staticElement);
  }

  @override
  void visitNamedType(NamedType node) {
    _recordPrefixedElement(node.importPrefix, node.element);
    super.visitNamedType(node);
  }

  void _recordPrefixedElement(
    ImportPrefixReference? importPrefix,
    Element? element,
  ) {
    if (element is MultiplyDefinedElement) {
      for (final component in element.conflictingElements) {
        _recordPrefixedElement(importPrefix, component);

        return;
      }
    }

    // Invalid code can use `importPrefix` as a named type;
    if (element is PrefixElement) {
      fileElementsUsage.prefixMap[element] ??= [];

      return;
    }

    if (importPrefix != null) {
      final prefixElement = importPrefix.element;
      if (prefixElement is PrefixElement) {
        final map = fileElementsUsage.prefixMap[prefixElement] ??= [];
        if (element != null) {
          map.add(element);
        }
      }
    } else if (element != null) {
      _recordUsedElement(element);
    }
  }

  void _recordAssignmentTarget(
    CompoundAssignmentExpression node,
    Expression target,
  ) {
    if (target is PrefixedIdentifier) {
      _visitIdentifier(target.identifier, node.readElement);
      _visitIdentifier(target.identifier, node.writeElement);
    } else if (target is PropertyAccess) {
      _visitIdentifier(target.propertyName, node.readElement);
      _visitIdentifier(target.propertyName, node.writeElement);
    } else if (target is SimpleIdentifier) {
      _visitIdentifier(target, node.readElement);
      _visitIdentifier(target, node.writeElement);
    }
  }

  void _recordIfExtensionMember(Element? element) {
    if (element != null) {
      final enclosingElement = element.enclosingElement;
      if (enclosingElement is ExtensionElement) {
        _recordUsedExtension(enclosingElement);
      }
    }
  }

  bool _recordConditionalElement(Element element) {
    final elementPath = element.enclosingElement?.source?.fullName;
    if (elementPath == null) {
      return false;
    }

    final entries = fileElementsUsage.conditionalElements.entries;
    for (final conditionalElement in entries) {
      if (conditionalElement.key.contains(elementPath)) {
        conditionalElement.value.add(element);

        return true;
      }
    }

    return false;
  }

  /// Records use of a not prefixed [element].
  void _recordUsedElement(Element element) {
    // Ignore if an unknown library.
    final containingLibrary = element.library;
    if (containingLibrary == null) {
      return;
    }
    // Remember the element.
    fileElementsUsage.elements.add(element);
  }

  void _recordUsedExtension(ExtensionElement extension) {
    // Remember the element.
    fileElementsUsage.usedExtensions.add(extension);
  }

  void _visitIdentifier(SimpleIdentifier identifier, Element? element) {
    if (element == null || element is PrefixElement) {
      return;
    }

    // Declarations are not a sign of usage.
    if (identifier.parent is Declaration &&
        !_isVariableDeclarationInitializer(identifier.parent, identifier)) {
      return;
    }

    // Usage in State<WidgetClassName> is not a sign of usage.
    if (_isUsedAsNamedTypeForWidgetState(identifier)) {
      return;
    }

    // Record elements that are imported with conditional imports
    if (_recordConditionalElement(element)) {
      return;
    }

    final enclosingElement = element.enclosingElement;
    if (enclosingElement is CompilationUnitElement) {
      _recordUsedElement(element);
    } else if (enclosingElement is ExtensionElement) {
      _recordUsedExtension(enclosingElement);

      return;
    } else if (element is MultiplyDefinedElement) {
      // If the element is multiply defined then call this method recursively
      // for each of the conflicting elements.
      final conflictingElements = element.conflictingElements;
      final length = conflictingElements.length;
      for (var index = 0; index < length; index++) {
        final elt = conflictingElements[index];
        _visitIdentifier(identifier, elt);
      }
    }
  }

  bool _isVariableDeclarationInitializer(
    AstNode? target,
    SimpleIdentifier identifier,
  ) =>
      target is VariableDeclaration && target.initializer == identifier;

  bool _isUsedAsNamedTypeForWidgetState(SimpleIdentifier identifier) {
    final grandGrandParent = identifier.parent?.parent?.parent;

    return grandGrandParent is NamedType &&
        isWidgetStateOrSubclass(grandGrandParent.type);
  }
}
