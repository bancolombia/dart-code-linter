// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'models/invocations_usage.dart';

class InvocationsVisitor extends RecursiveAstVisitor<void> {
  final invocationsUsages = InvocationsUsage();

  @override
  void visitExportDirective(ExportDirective node) {
    super.visitExportDirective(node);

    final uri = node.libraryExport?.uri;
    if (uri is DirectiveUriWithSource) {
      invocationsUsages.exports.add(uri.source.fullName);
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    super.visitPropertyAccess(node);

    if (node.propertyName.staticType is FunctionType) {
      _recordUsedElement(node.propertyName.element, null);
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    super.visitPrefixedIdentifier(node);

    if (node.identifier.staticType is FunctionType) {
      _recordUsedElement(node.identifier.element, null);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    _recordUsedElement(node.methodName.element, node.argumentList);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    super.visitFunctionExpressionInvocation(node);

    _recordUsedElement(node.element, node.argumentList);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    _recordUsedElement(node.constructorName.element, node.argumentList);
  }

  /// Records use of a not prefixed [element].
  void _recordUsedElement(Element? element, ArgumentList? arguments) {
    if (element == null) {
      return;
    }
    // Ignore if an unknown library.
    final containingLibrary = element.library;
    if (containingLibrary == null) {
      return;
    }
    // Remember the element.
    final usedArguments = arguments == null ? null : {arguments};
    invocationsUsages.addElementUsage(element, usedArguments);
  }
}
