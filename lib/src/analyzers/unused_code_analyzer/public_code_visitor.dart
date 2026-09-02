// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../../utils/node_utils.dart';
import '../../utils/suppression.dart';

class PublicCodeVisitor extends GeneralizingAstVisitor<void> {
  final Set<Element> topLevelElements = {};

  /// Declarations that could be made private if nothing outside their library
  /// turns out to reference them.
  ///
  /// Deliberately a separate set rather than a filter over [topLevelElements]:
  /// the two verdicts have different eligibility rules, and the unused
  /// candidates must keep behaving exactly as they did before suggestions
  /// existed. A declaration can be in both sets, in neither, or in one alone.
  final Set<Element> privatizableElements = {};

  final Suppression _suppression;
  final String _pattern;
  final bool _analyzePrivateMembers;
  final bool _analyzePublicMembers;
  final bool _suggestPrivateMembers;

  PublicCodeVisitor(
    this._suppression,
    this._pattern, {
    bool analyzePrivateMembers = false,
    bool analyzePublicMembers = false,
    bool suggestPrivateMembers = false,
  })  : _analyzePrivateMembers = analyzePrivateMembers,
        _analyzePublicMembers = analyzePublicMembers,
        _suggestPrivateMembers = suggestPrivateMembers;

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

    _getTopLevelElement(node, node.metadata);

    if ((_analyzePrivateMembers ||
            _analyzePublicMembers ||
            _suggestPrivateMembers) &&
        _isTypeDeclaration(node)) {
      // Descend into the type body with a recursive visitor. The shape of the
      // members container (`ClassDeclaration.members` vs `body.members`) changed
      // across supported analyzer versions, so we rely on the visitor dispatch
      // for `MethodDeclaration`/`FieldDeclaration`, which is stable, instead of
      // typed member accessors.
      final memberVisitor = _MemberVisitor(
        topLevelElements,
        privatizableElements,
        _suppression,
        _pattern,
        enclosingMetadata: node.metadata,
        hierarchyUnresolved: _hasUnresolvedHierarchyClause(node),
        analyzePrivateMembers: _analyzePrivateMembers,
        analyzePublicMembers: _analyzePublicMembers,
        suggestPrivateMembers: _suggestPrivateMembers,
      );
      node.accept(memberVisitor);
      // Suggestions cannot be settled during the walk: whether a field can be
      // renamed depends on the constructors, which may sit below it.
      memberVisitor.finish();
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
      // The annotations of a variable sit on the enclosing declaration, not on
      // the variable itself.
      _getTopLevelElement(variables.first, node.metadata);
    }
  }

  void _getTopLevelElement(Declaration node, Iterable<Annotation> metadata) {
    final element = node.declaredFragment?.element;

    if (element == null) {
      return;
    }

    topLevelElements.add(element);

    if (_suggestPrivateMembers && _isPrivatizableTopLevel(element, metadata)) {
      privatizableElements.add(element);
    }
  }

  /// Whether [element] is a top level declaration that could carry a private
  /// name, leaving aside whether anything outside its library references it.
  ///
  /// Unlike a member, a top level declaration needs no override or dispatch
  /// reasoning: a subtype, an implementation or a reference from another
  /// library all name the declaration itself, so ordinary usage tracking
  /// already sees them. Only the reachability annotations have to be read
  /// here, plus `main` and the Flutter entry points, which
  /// [visitCompilationUnitMember] has already dropped before this runs.
  bool _isPrivatizableTopLevel(Element element, Iterable<Annotation> metadata) =>
      !element.isPrivate &&
      !hasEntryPointPragma(metadata) &&
      !_hasJSInteropAnnotation(metadata) &&
      !element.metadata.hasVisibleForTesting;

  bool _isTypeDeclaration(CompilationUnitMember node) =>
      node is ClassDeclaration ||
      node is MixinDeclaration ||
      node is EnumDeclaration ||
      node is ExtensionDeclaration ||
      node is ExtensionTypeDeclaration;

  /// Whether [node]'s own `extends`/`implements`/`with`/`on` clause names a
  /// type that failed to resolve (a broken import, the unselected branch of a
  /// conditional import, an unrelated resolution error elsewhere in the
  /// hierarchy).
  ///
  /// A failure here means `InterfaceElement.allSupertypes` for [node]'s
  /// declared element silently comes back incomplete: the analyzer's recovery
  /// drops the unresolved supertype and everything above it rather than
  /// erroring, so a subtype cut off this way still resolves the rest of its
  /// hierarchy correctly (only the type declared directly on [node] loses
  /// visibility into what it may be overriding). See `_isDeclaredBySupertype`
  /// on `_MemberVisitor`, which uses this to fall back to treating every
  /// member of such a type as possibly inherited, rather than risk a false
  /// positive from a hierarchy it cannot see all of.
  bool _hasUnresolvedHierarchyClause(CompilationUnitMember node) {
    bool isUnresolved(NamedType type) => type.type is InvalidType;
    bool anyUnresolved(NodeList<NamedType>? types) =>
        types?.any(isUnresolved) ?? false;

    return switch (node) {
      ClassDeclaration() => (node.extendsClause != null &&
              isUnresolved(node.extendsClause!.superclass)) ||
          anyUnresolved(node.implementsClause?.interfaces) ||
          anyUnresolved(node.withClause?.mixinTypes),
      MixinDeclaration() =>
        anyUnresolved(node.onClause?.superclassConstraints) ||
            anyUnresolved(node.implementsClause?.interfaces),
      EnumDeclaration() => anyUnresolved(node.implementsClause?.interfaces) ||
          anyUnresolved(node.withClause?.mixinTypes),
      ExtensionTypeDeclaration() =>
        anyUnresolved(node.implementsClause?.interfaces),
      // Extensions have no supertype in the sense [_isDeclaredBySupertype]
      // cares about: `ExtensionElement` is never an `InterfaceElement`.
      _ => false,
    };
  }
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
  final Set<Element> _privatizableElements;
  final Suppression _suppression;
  final String _pattern;
  final bool _analyzePrivateMembers;
  final bool _analyzePublicMembers;
  final bool _suggestPrivateMembers;

  /// Suggestion candidates found so far, each with the name of the field it
  /// declares, or `null` when it is not a field. Settled by [finish].
  final List<(Element, String?)> _pendingSuggestions = [];

  /// Names of fields bound by a named `this.x` or `super.x` formal.
  ///
  /// Such a field cannot be renamed to a private name: Dart forbids a named
  /// parameter starting with an underscore, so `this._x` does not compile in
  /// a named parameter position, and the rename is impossible even for a
  /// constructor nothing outside the library calls.
  final Set<String> _namedFormalFieldNames = {};

  /// Whether the enclosing type carries `@JSExport`, which exports every one of
  /// its instance members to JavaScript.
  ///
  /// This is the one annotation worth reading off the enclosing declaration.
  /// `@pragma('vm:entry-point')` deliberately is not: on a class it only means
  /// the class may be allocated from native or VM code, and each member still
  /// needs its own pragma to be retained, so walking up for it would hide
  /// genuinely dead members. See
  /// https://github.com/dart-lang/sdk/blob/master/runtime/docs/compiler/aot/entry_point_pragma.md
  final bool _enclosingIsJSExported;

  /// Whether the enclosing type's own `extends`/`implements`/`with`/`on`
  /// clause names a type that failed to resolve, making its
  /// `allSupertypes` incomplete. See [_isDeclaredBySupertype].
  final bool _hierarchyUnresolved;

  /// Names of all members declared by supertypes, computed on first use.
  final Map<InterfaceElement, Set<String>> _inheritedNames = {};

  _MemberVisitor(
    this._elements,
    this._privatizableElements,
    this._suppression,
    this._pattern, {
    required Iterable<Annotation> enclosingMetadata,
    required bool hierarchyUnresolved,
    required bool analyzePrivateMembers,
    required bool analyzePublicMembers,
    required bool suggestPrivateMembers,
  })  : _enclosingIsJSExported = hasJSExportAnnotation(enclosingMetadata),
        _hierarchyUnresolved = hierarchyUnresolved,
        _analyzePrivateMembers = analyzePrivateMembers,
        _analyzePublicMembers = analyzePublicMembers,
        _suggestPrivateMembers = suggestPrivateMembers;

  /// Promotes the suggestion candidates that survived the whole type body.
  ///
  /// Must be called once the type declaration has been fully visited.
  void finish() {
    for (final (element, fieldName) in _pendingSuggestions) {
      if (fieldName == null || !_namedFormalFieldNames.contains(fieldName)) {
        _privatizableElements.add(element);
      }
    }
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    if (node.isNamed) {
      _namedFormalFieldNames.add(node.name.lexeme);
    }

    super.visitFieldFormalParameter(node);
  }

  @override
  void visitSuperFormalParameter(SuperFormalParameter node) {
    // A `super.x` formal binds a field of a supertype rather than one declared
    // here, but the two share a name often enough that the cheap, conservative
    // reading is the right one: a skipped suggestion costs nothing.
    if (node.isNamed) {
      _namedFormalFieldNames.add(node.name.lexeme);
    }

    super.visitSuperFormalParameter(node);
  }

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

    // Enum constant names follow the same privacy rules as any other member
    // (`_hidden` is library-scoped, not enum-scoped), so `_addCandidate`
    // routes a private-named constant to analyzePrivateMembers rather than
    // analyzePublicMembers, exactly like a private field or method. A
    // constant reached exclusively through `values` (iteration, `byName`,
    // deserialization) is marked used by the usage visitor, which records
    // every constant of an enum whose `values` is referenced.
    _addCandidate(node.declaredFragment?.element, node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    // Descend into the formals first, and whatever the verdict below is: a
    // named `this.x` formal blocks its field from being renamed even when the
    // constructor holding it is suppressed or is not a candidate itself. The
    // other member visits deliberately do not recurse, since nothing below
    // them declares a member.
    super.visitConstructorDeclaration(node);

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

    // Everything unreachable through a reference is out of both verdicts: an
    // analysis that cannot see how a member is called cannot tell that the
    // calls all sit in one library either.
    if (_isReachableWithoutReference(element, node)) {
      return;
    }

    if (_analyzePublicMembers) {
      _elements.add(element);
    }

    if (_suggestPrivateMembers &&
        _canBeRenamedPrivate(node) &&
        !_enclosingTypeIsPrivate(element)) {
      _pendingSuggestions
          .add((element, node is FieldDeclaration ? element.name : null));
    }
  }

  /// Whether the type declaring [element] is itself private.
  ///
  /// For most kinds the rename is then simply pointless: no other library can
  /// name the type, so nothing out there was reaching the member to begin
  /// with. For a mixin it is more than pointless, since a public class can mix
  /// a private mixin in and republish its members under a name other
  /// libraries do reach, so skipping is the right direction for the whole
  /// group rather than only its harmless part.
  ///
  /// The name check is load bearing rather than defensive: [Element.isPrivate]
  /// answers `true` for a null name, which is what an *unnamed* extension has.
  /// Its members apply in every library that imports this one, so it is a
  /// genuine candidate and must not be swept up here. Pinned by the
  /// `private_enclosing_types.dart` fixture.
  bool _enclosingTypeIsPrivate(Element element) {
    final enclosingElement = element.enclosingElement;

    return enclosingElement != null &&
        enclosingElement.name != null &&
        enclosingElement.isPrivate;
  }

  /// Whether the member [node] declares could carry a private name at all.
  ///
  /// Separate from [_isReachableWithoutReference], which is about not seeing
  /// the callers: these members have perfectly visible callers, they just
  /// cannot be renamed.
  bool _canBeRenamedPrivate(AnnotatedNode node) => switch (node) {
        // `operator +` has no private spelling.
        MethodDeclaration() => node.operatorKeyword == null,
        // An enum constant's identifier is observable at run time through
        // `name` and `toString`, so renaming one can silently change
        // serialized output in a way no reference based analysis can see.
        EnumConstantDeclaration() => false,
        _ => true,
      };

  /// Whether [element] can be reached without any reference to it that the
  /// usage visitor could record.
  bool _isReachableWithoutReference(Element element, AnnotatedNode node) =>
      _conventionallyCalledNames.contains(element.name) ||
      _isDeclaredBySupertype(element) ||
      _hasReachabilityAnnotation(element) ||
      hasEntryPointPragma(node.metadata) ||
      // Exported to JavaScript either by the enclosing type, which wraps only
      // its instance members, or by this member's own annotation.
      (_enclosingIsJSExported && _isInstanceMember(node)) ||
      _hasJSInteropAnnotation(node.metadata);

  /// Whether [node] declares an instance member, the only kind that a class
  /// level `@JSExport` wraps.
  ///
  /// The `JSExport` doc says only *concrete* instance members are wrapped. An
  /// abstract one is not treated specially here: on a class being instance
  /// wrapped that is a strange thing to write, and an abstract member is
  /// normally implemented by a subtype, which [_isDeclaredBySupertype] already
  /// covers from the other side.
  bool _isInstanceMember(AnnotatedNode node) => switch (node) {
        MethodDeclaration() => !node.isStatic,
        FieldDeclaration() => !node.isStatic,
        // Enum constants and constructors are never instance members.
        _ => false,
      };

  /// Whether a supertype declares a member of the same name.
  ///
  /// Such a member is reached through dispatch on the supertype, which resolves
  /// to the supertype's declaration rather than to this one, so no recorded
  /// usage ever points here. Every `toString`, `hashCode` and `noSuchMethod` is
  /// covered by this, since `Object` is a supertype of everything.
  ///
  /// A constructor is never declared by a supertype in this sense: a
  /// constructor's name lives in a separate namespace from instance members,
  /// so a supertype method or field of the same name is unrelated and must
  /// not exempt a dead named constructor.
  ///
  /// When [_hierarchyUnresolved] is set, [_inheritedNamesOf] cannot be
  /// trusted: the enclosing type's own hierarchy failed to resolve, so
  /// `allSupertypes` silently came back incomplete and may be missing the
  /// very supertype a member here overrides. Every member of such a type is
  /// then treated as possibly declared by a supertype, favoring a missed
  /// detection over reporting a genuinely used override as dead code.
  bool _isDeclaredBySupertype(Element element) {
    final enclosingElement = element.enclosingElement;
    final name = element.name;
    if (element is ConstructorElement ||
        enclosingElement is! InterfaceElement ||
        name == null) {
      return false;
    }

    return _hierarchyUnresolved ||
        _inheritedNamesOf(enclosingElement).contains(name);
  }

  Set<String> _inheritedNamesOf(InterfaceElement element) =>
      _inheritedNames.putIfAbsent(element, () {
        final names = <String?>{};

        // Statics are excluded: they are never inherited, so a static member
        // on a supertype does not put a same-named instance member on this
        // type in reach of dispatch on the supertype.
        for (final supertype in element.allSupertypes) {
          final supertypeElement = supertype.element;
          names
            ..addAll(supertypeElement.methods
                .where((member) => !member.isStatic)
                .map((member) => member.name))
            ..addAll(supertypeElement.getters
                .where((member) => !member.isStatic)
                .map((member) => member.name))
            ..addAll(supertypeElement.setters
                .where((member) => !member.isStatic)
                .map((member) => member.name))
            ..addAll(supertypeElement.fields
                .where((member) => !member.isStatic)
                .map((member) => member.name));
        }

        return names.nonNulls.toSet();
      });

  /// Whether [element] is annotated to say it is reached from somewhere the
  /// analysis cannot see, or from a subtype rather than through a reference.
  bool _hasReachabilityAnnotation(Element element) {
    final metadata = element.metadata;

    // `@override` and `@redeclare` are redundant with [_isDeclaredBySupertype],
    // since both are only valid on a member that has an inherited counterpart
    // of the same name. Kept anyway as a cheap fast path that avoids walking
    // `allSupertypes` at all.
    return metadata.hasOverride ||
        metadata.hasRedeclare ||
        // The rest say nothing about the hierarchy, so only the annotation can
        // rule these out.
        metadata.hasMustBeOverridden ||
        metadata.hasVisibleForOverriding ||
        metadata.hasProtected ||
        metadata.hasVisibleForTesting;
    // The JS interop annotations are handled in
    // [_isReachableWithoutReference] instead of here, by name rather than
    // through the resolved element. See [_hasJSInteropAnnotation].
  }
}

/// Whether [metadata] carries `@JSExport` or `@JS`, checked in a single
/// pass over [metadata] rather than two.
///
/// `@JSExport` marks a declaration JavaScript calls through
/// `createJSInteropWrapper`. `@JS` is the one case here that is not about
/// reachability: its callers are Dart-side and visible, so an unreferenced
/// one is reportable in principle. Skipped anyway, because an interop
/// binding surface is normally written complete on purpose and reporting
/// the unused part of it is noise rather than a finding. Pinned by the
/// `js_binding_members.dart` fixture.
///
/// The `'JSExport'` half of the check below duplicates [hasJSExportAnnotation]
/// rather than calling it, to keep this a single pass over [metadata].
/// Flagged in review as worth reusing the helper instead, at the cost of a
/// second pass over a metadata list that in practice holds a handful of
/// annotations at most; left as-is pending a maintainer call on whether
/// that single-pass saving is worth the duplication.
bool _hasJSInteropAnnotation(Iterable<Annotation> metadata) => metadata.any(
      (annotation) => switch (annotationName(annotation)) {
        'JSExport' || 'JS' => true,
        _ => false,
      },
    );
