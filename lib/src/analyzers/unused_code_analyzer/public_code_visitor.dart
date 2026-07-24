// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../../utils/node_utils.dart';
import '../../utils/suppression.dart';

class PublicCodeVisitor extends GeneralizingAstVisitor<void> {
  final Set<Element> topLevelElements = {};

  final Suppression _suppression;
  final String _pattern;
  final bool _analyzePrivateMembers;

  PublicCodeVisitor(
    this._suppression,
    this._pattern, {
    bool analyzePrivateMembers = false,
  }) : _analyzePrivateMembers = analyzePrivateMembers;

  @override
  void visitCompilationUnitMember(CompilationUnitMember node) {
    final lineIndex = _suppression.lineInfo.getLocation(node.offset).lineNumber;
    if (_suppression.isSuppressedAt(_pattern, lineIndex)) {
      return;
    }

    if (node is FunctionDeclaration) {
      if (isEntrypoint(node.name.lexeme, node.metadata)) {
        return;
      }
    }

    _getTopLevelElement(node);

    if (_analyzePrivateMembers && _isTypeDeclaration(node)) {
      // Descend into the type body with a recursive visitor. The shape of the
      // members container (`ClassDeclaration.members` vs `body.members`) changed
      // across supported analyzer versions, so we rely on the visitor dispatch
      // for `MethodDeclaration`/`FieldDeclaration`, which is stable, instead of
      // typed member accessors.
      node.accept(
        _PrivateMemberVisitor(topLevelElements, _suppression, _pattern),
      );
    }
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    final lineIndex = _suppression.lineInfo.getLocation(node.offset).lineNumber;
    if (_suppression.isSuppressedAt(_pattern, lineIndex)) {
      return;
    }

    final variables = node.variables.variables;

    if (variables.isNotEmpty) {
      _getTopLevelElement(variables.first);
    }
  }

  void _getTopLevelElement(Declaration node) {
    final element = node.declaredFragment?.element;

    if (element != null) {
      topLevelElements.add(element);
    }
  }

  bool _isTypeDeclaration(CompilationUnitMember node) =>
      node is ClassDeclaration ||
      node is MixinDeclaration ||
      node is EnumDeclaration ||
      node is ExtensionDeclaration ||
      node is ExtensionTypeDeclaration;
}

/// Collects private members (methods, fields, getters, setters and named
/// constructors) of a single type declaration as unused-code candidates.
///
/// Only private members are considered: they cannot be referenced from
/// outside the declaring library, which rules out the reflection and
/// cross-library false positives that make public members unreliable to
/// analyze. Note that privacy is library-scoped, not class-scoped, so a
/// private member can still be overridden or implemented by another type in
/// the same library; usage tracking does not currently guard against that
/// (tracked as a known limitation, not yet a reported false positive because
/// of how usage matching happens to fall back to same-name-in-library
/// matching).
class _PrivateMemberVisitor extends RecursiveAstVisitor<void> {
  final Set<Element> _elements;
  final Suppression _suppression;
  final String _pattern;

  _PrivateMemberVisitor(this._elements, this._suppression, this._pattern);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (_isSuppressed(node)) {
      return;
    }

    _addIfPrivate(node.declaredFragment?.element);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (_isSuppressed(node)) {
      return;
    }

    for (final variable in node.fields.variables) {
      _addIfPrivate(variable.declaredFragment?.element);
    }
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (_isSuppressed(node)) {
      return;
    }

    // Only named constructors can be candidates: privacy is determined by the
    // identifier, and an unnamed constructor has none (its element is named
    // `new`, so `isPrivate` is naturally false). Primary constructors of
    // extension types are part of the type declaration itself, not
    // `ConstructorDeclaration` nodes, so they never reach this visitor.
    final element = node.declaredFragment?.element;
    if (element == null || !element.isPrivate) {
      return;
    }

    // Mirror the SDK's unused_element carve-out: a sole private constructor
    // exists to prevent instantiation or extension, which counts as usage.
    // This hides no dead code: an entirely unused class is still reported by
    // the top-level check in [PublicCodeVisitor], independent of this visitor.
    if (element.enclosingElement.constructors.length <= 1) {
      return;
    }

    _elements.add(element);
  }

  bool _isSuppressed(AstNode node) {
    final lineIndex = _suppression.lineInfo.getLocation(node.offset).lineNumber;

    return _suppression.isSuppressedAt(_pattern, lineIndex);
  }

  void _addIfPrivate(Element? element) {
    if (element != null && element.isPrivate) {
      _elements.add(element);
    }
  }
}
