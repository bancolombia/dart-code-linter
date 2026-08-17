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
  final bool _analyzePublicMembers;

  PublicCodeVisitor(
    this._suppression,
    this._pattern, {
    bool analyzePrivateMembers = false,
    bool analyzePublicMembers = false,
  })  : _analyzePrivateMembers = analyzePrivateMembers,
        _analyzePublicMembers = analyzePublicMembers;

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

    if ((_analyzePrivateMembers || _analyzePublicMembers) &&
        _isTypeDeclaration(node)) {
      // Descend into the type body with a recursive visitor. The shape of the
      // members container (`ClassDeclaration.members` vs `body.members`) changed
      // across supported analyzer versions, so we rely on the visitor dispatch
      // for `MethodDeclaration`/`FieldDeclaration`, which is stable, instead of
      // typed member accessors.
      node.accept(_MemberVisitor(
        topLevelElements,
        _suppression,
        _pattern,
        analyzePrivateMembers: _analyzePrivateMembers,
        analyzePublicMembers: _analyzePublicMembers,
      ));
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

/// Collects members (methods, fields, getters, setters, named constructors and
/// enum constants) of a single type declaration as unused-code candidates.
///
/// Private members are collected when `analyzePrivateMembers` is set. They
/// cannot be referenced from outside the declaring library, which rules out the
/// reflection and cross-library false positives that make public members
/// harder to analyze. Note that privacy is library-scoped, not class-scoped, so
/// a private member can still be overridden or implemented by another type in
/// the same library; usage tracking does not currently guard against that
/// (tracked as a known limitation, not yet a reported false positive because
/// of how usage matching happens to fall back to same-name-in-library
/// matching).
///
/// Public members are collected when `analyzePublicMembers` is set, minus the
/// ones that are reachable in ways whole-program usage tracking cannot see:
/// members that override or implement an inherited member (dispatch resolves to
/// the supertype declaration, not to this one), and members annotated to say
/// they are called from elsewhere.
///
/// Unnamed constructors are never candidates, for either mode: invocations of
/// them carry no identifier for the usage visitor to record, so every one of
/// them would look unused.
class _MemberVisitor extends RecursiveAstVisitor<void> {
  /// Members that the SDK calls by convention rather than through a reference:
  /// `json.encode` invokes `toJson` on the object it is handed, so a `toJson`
  /// never appears in the source of the code that calls it.
  static const _conventionallyCalledNames = {'toJson'};

  final Set<Element> _elements;
  final Suppression _suppression;
  final String _pattern;
  final bool _analyzePrivateMembers;
  final bool _analyzePublicMembers;

  /// Names of all members declared by supertypes, computed on first use.
  final Map<InterfaceElement, Set<String>> _inheritedNames = {};

  _MemberVisitor(
    this._elements,
    this._suppression,
    this._pattern, {
    required bool analyzePrivateMembers,
    required bool analyzePublicMembers,
  })  : _analyzePrivateMembers = analyzePrivateMembers,
        _analyzePublicMembers = analyzePublicMembers;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (_isSuppressed(node)) {
      return;
    }

    _addCandidate(node.declaredFragment?.element, node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (_isSuppressed(node)) {
      return;
    }

    for (final variable in node.fields.variables) {
      _addCandidate(variable.declaredFragment?.element, node);
    }
  }

  @override
  void visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    if (_isSuppressed(node)) {
      return;
    }

    // Enum constants are always public members of the enum, so they only take
    // part in the public members analysis. A constant reached exclusively
    // through `values` (iteration, `byName`, deserialization) is marked used by
    // the usage visitor, which records every constant of an enum whose `values`
    // is referenced.
    _addCandidate(node.declaredFragment?.element, node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (_isSuppressed(node)) {
      return;
    }

    // Only named constructors can be candidates: an invocation of an unnamed
    // constructor has no identifier for the usage visitor to record, and
    // privacy is determined by the identifier, which an unnamed constructor
    // does not have (its element is named `new`, so `isPrivate` is naturally
    // false). Primary constructors of extension types are part of the type
    // declaration itself, not `ConstructorDeclaration` nodes, so they never
    // reach this visitor.
    final element = node.declaredFragment?.element;
    if (element == null || node.name == null) {
      return;
    }

    // Mirror the SDK's unused_element carve-out: a sole private constructor
    // exists to prevent instantiation or extension, which counts as usage.
    // This hides no dead code: an entirely unused class is still reported by
    // the top-level check in [PublicCodeVisitor], independent of this visitor.
    if (element.isPrivate && element.enclosingElement.constructors.length <= 1) {
      return;
    }

    _addCandidate(element, node);
  }

  bool _isSuppressed(AstNode node) {
    final lineIndex = _suppression.lineInfo.getLocation(node.offset).lineNumber;

    return _suppression.isSuppressedAt(_pattern, lineIndex);
  }

  void _addCandidate(Element? element, AnnotatedNode node) {
    if (element == null) {
      return;
    }

    if (element.isPrivate) {
      if (_analyzePrivateMembers) {
        _elements.add(element);
      }

      return;
    }

    if (_analyzePublicMembers && !_isReachableWithoutReference(element, node)) {
      _elements.add(element);
    }
  }

  /// Whether [element] can be reached without any reference to it that the
  /// usage visitor could record.
  bool _isReachableWithoutReference(Element element, AnnotatedNode node) =>
      _conventionallyCalledNames.contains(element.name) ||
      _isDeclaredBySupertype(element) ||
      _hasReachabilityAnnotation(element) ||
      hasEntryPointPragma(node.metadata);

  /// Whether a supertype declares a member of the same name.
  ///
  /// Such a member is reached through dispatch on the supertype, which resolves
  /// to the supertype's declaration rather than to this one, so no recorded
  /// usage ever points here. Every `toString`, `hashCode` and `noSuchMethod` is
  /// covered by this, since `Object` is a supertype of everything.
  bool _isDeclaredBySupertype(Element element) {
    final enclosingElement = element.enclosingElement;
    final name = element.name;
    if (enclosingElement is! InterfaceElement || name == null) {
      return false;
    }

    return _inheritedNamesOf(enclosingElement).contains(name);
  }

  Set<String> _inheritedNamesOf(InterfaceElement element) =>
      _inheritedNames.putIfAbsent(element, () {
        final names = <String?>{};

        for (final supertype in element.allSupertypes) {
          final supertypeElement = supertype.element;
          names
            ..addAll(supertypeElement.methods.map((member) => member.name))
            ..addAll(supertypeElement.getters.map((member) => member.name))
            ..addAll(supertypeElement.setters.map((member) => member.name))
            ..addAll(supertypeElement.fields.map((member) => member.name));
        }

        return names.nonNulls.toSet();
      });

  /// Whether [element] is annotated to say it is reached from somewhere the
  /// analysis cannot see, or from a subtype rather than through a reference.
  bool _hasReachabilityAnnotation(Element element) {
    final metadata = element.metadata;

    // `@override` and `@redeclare` are redundant with [_isDeclaredBySupertype]
    // whenever the hierarchy resolves, since both are only valid on a member
    // that has an inherited counterpart of the same name. They are kept as a
    // cheap fast path that still holds when a supertype fails to resolve and
    // `allSupertypes` comes back empty.
    return metadata.hasOverride ||
        metadata.hasRedeclare ||
        // The rest say nothing about the hierarchy, so only the annotation can
        // rule these out.
        metadata.hasMustBeOverridden ||
        metadata.hasVisibleForOverriding ||
        metadata.hasProtected ||
        metadata.hasVisibleForTesting ||
        // `@JS` members are called from JavaScript. Not covered by a fixture:
        // it needs `package:js`, which this package does not depend on.
        metadata.hasJS;
  }
}
