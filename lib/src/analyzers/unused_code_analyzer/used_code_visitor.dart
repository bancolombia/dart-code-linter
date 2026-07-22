// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../../utils/flutter_types_utils.dart';
import 'models/file_elements_usage.dart';

// Copied from https://github.com/dart-lang/sdk/blob/main/pkg/analyzer/lib/src/error/imports_verifier.dart#L15

class UsedCodeVisitor extends RecursiveAstVisitor<void> {
  final fileElementsUsage = FileElementsUsage();

  final bool _recordClassMembers;

  UsedCodeVisitor({bool recordClassMembers = false})
      : _recordClassMembers = recordClassMembers;

  @override
  void visitImportDirective(ImportDirective node) {
    if (node.configurations.isNotEmpty) {
      final configPaths = node.configurations
          .map((config) {
            final uri = config.resolvedUri;

            return (uri is DirectiveUriWithSource) ? uri.source.fullName : null;
          })
          .nonNulls
          .toSet();

      final mainUriString = node.uri.stringValue;
      final compilationUnit = node.root as CompilationUnit;
      final declaredFragment = compilationUnit.declaredFragment;
      final currentSource = declaredFragment?.source;

      String? mainImport;
      if (currentSource != null && mainUriString != null) {
        try {
          mainImport = currentSource.uri.resolve(mainUriString).toFilePath();
        } on Object catch (_) {
          final uri = node.libraryImport?.uri;
          if (uri is DirectiveUriWithLibrary) {
            mainImport = uri.library.firstFragment.source.fullName;
          }
        }
      }

      final allPaths = {if (mainImport != null) mainImport, ...configPaths};

      fileElementsUsage.conditionalElements.update(
        allPaths,
        (conditionalElements) => conditionalElements,
        ifAbsent: () => {},
      );

      fileElementsUsage.conditionalFiles.addAll(configPaths);
    }

    super.visitImportDirective(node);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    super.visitExportDirective(node);

    final uri = node.libraryExport?.uri;

    final path = uri is DirectiveUriWithLibrary
        ? uri.library.firstFragment.source.fullName
        : null;
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
    _recordIfExtensionMember(node.element);

    super.visitBinaryExpression(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _recordIfExtensionMember(node.element);

    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    _recordIfExtensionMember(node.element);

    super.visitIndexExpression(node);
  }

  @override
  void visitPatternField(PatternField node) {
    // The member name in an object pattern is a plain token, not a
    // SimpleIdentifier, so visitSimpleIdentifier never sees it.
    final element = node.element;
    _recordIfExtensionMember(element);
    if (_recordClassMembers && element != null) {
      final enclosingElement = element.enclosingElement;
      if (enclosingElement is InterfaceElement ||
          enclosingElement is ExtensionElement) {
        _recordUsedElement(element);
      }
    }

    super.visitPatternField(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _recordAssignmentTarget(node, node.operand);

    super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _recordAssignmentTarget(node, node.operand);
    _recordIfExtensionMember(node.element);

    super.visitPrefixExpression(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _visitIdentifier(node, node.element);
  }

  @override
  void visitNamedType(NamedType node) {
    if (_isUsedInWidgetStateClassDeclaration(node)) {
      return;
    }
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

  void _recordConditionalElement(Element element) {
    final elementPath = element
        .enclosingElement?.firstFragment.libraryFragment?.source.fullName;
    if (elementPath == null) {
      return;
    }

    final entries = fileElementsUsage.conditionalElements.entries;
    for (final conditionalElement in entries) {
      if (conditionalElement.key.contains(elementPath)) {
        conditionalElement.value.add(element);
      }
    }
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
    _recordConditionalElement(element);

    final enclosingElement = element.enclosingElement;

    if (enclosingElement is LibraryElement ||
        enclosingElement is LibraryFragment) {
      _recordUsedElement(element);
    } else if (_recordClassMembers &&
        enclosingElement is InterfaceElement) {
      _recordUsedElement(element);
    } else if (enclosingElement is ExtensionElement) {
      _recordUsedExtension(enclosingElement);

      if (_recordClassMembers) {
        _recordUsedElement(element);
      }

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

  bool _isUsedInWidgetStateClassDeclaration(NamedType namedType) {
    final parent = namedType.parent;
    if (parent is TypeArgumentList) {
      final grandParent = parent.parent;

      return grandParent is NamedType &&
          isWidgetStateOrSubclass(grandParent.type);
    }

    return false;
  }
}
