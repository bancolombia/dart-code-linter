// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../../utils/flutter_types_utils.dart';
import 'element_utils.dart';
import 'models/file_elements_usage.dart';

// Copied from https://github.com/dart-lang/sdk/blob/main/pkg/analyzer/lib/src/error/imports_verifier.dart#L15

class UsedCodeVisitor extends RecursiveAstVisitor<void> {
  static const _enumValuesName = 'values';

  final fileElementsUsage = FileElementsUsage();

  final bool _recordClassMembers;

  /// Whether to collect the extra information the could be private
  /// suggestions need: which references come from another library, and which
  /// members a foreign subtype redeclares.
  final bool _recordPrivatizationBlockers;

  /// The library of the unit being visited, against which a reference is
  /// local or foreign.
  final LibraryElement? _library;

  UsedCodeVisitor({
    bool recordClassMembers = false,
    bool recordPrivatizationBlockers = false,
    LibraryElement? library,
  })  : _recordClassMembers = recordClassMembers,
        _recordPrivatizationBlockers = recordPrivatizationBlockers,
        _library = library;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _recordRedeclaredInheritedMembers(node.declaredFragment?.element);

    super.visitClassDeclaration(node);
  }

  @override
  void visitClassTypeAlias(ClassTypeAlias node) {
    // `class S = Base with M;` inherits and mixes in exactly like the body
    // form, so it blocks privatization the same way.
    _recordRedeclaredInheritedMembers(node.declaredFragment?.element);

    super.visitClassTypeAlias(node);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    _recordRedeclaredInheritedMembers(node.declaredFragment?.element);

    super.visitEnumDeclaration(node);
  }

  @override
  void visitExtensionTypeDeclaration(ExtensionTypeDeclaration node) {
    _recordRedeclaredInheritedMembers(node.declaredFragment?.element);

    super.visitExtensionTypeDeclaration(node);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _recordRedeclaredInheritedMembers(node.declaredFragment?.element);

    super.visitMixinDeclaration(node);
  }

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
    // `a += b` reaches the combiner `operator +` without naming it.
    _recordMemberUsage(node.element);
    _recordDynamicOperator(node.element, _assignmentOperatorName(node.operator));

    super.visitAssignmentExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _recordMemberUsage(node.element);
    _recordDynamicOperator(node.element, _binaryOperatorName(node.operator));

    super.visitBinaryExpression(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _recordMemberUsage(node.element);
    // An invocation of an unknown type reaches any `call` member. One of an
    // actual function type reaches none, so it records nothing.
    if (node.function.staticType is DynamicType) {
      _recordDynamicOperator(node.element, 'call');
    }

    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    // An index expression that is the target of an assignment, an increment
    // or a decrement is resolved through `resolveForWrite`, which never sets
    // `node.element`; the read/write elements live on the enclosing
    // `CompoundAssignmentExpression` instead and are recorded from there, in
    // `_recordAssignmentTarget`. Treating a null `node.element` as "reached
    // through a dynamic target" here would mark `[]`/`[]=` used everywhere in
    // the program on every ordinary, statically typed index write.
    if (!node.inSetterContext()) {
      _recordMemberUsage(node.element);
      _recordDynamicOperator(node.element, '[]');
    }

    super.visitIndexExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.realTarget?.staticType is! RecordType) {
      _recordDynamicUsage(node.methodName);
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.realTarget.staticType is! RecordType) {
      _recordDynamicUsage(node.propertyName);
    }

    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.staticType is! RecordType) {
      _recordDynamicUsage(node.identifier);
    }

    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    // The constructor selector of an enum constant is not resolved like an
    // ordinary identifier, so visitSimpleIdentifier never records it.
    // `baseElement` unwraps the member produced by generic enums.
    if (_recordClassMembers) {
      final constructor = node.constructorElement?.baseElement;
      if (constructor != null) {
        _recordUsedElement(constructor);
      }
    }

    super.visitEnumConstantDeclaration(node);
  }

  @override
  void visitPatternField(PatternField node) {
    // The member name in an object pattern is a plain token, not a
    // SimpleIdentifier, so visitSimpleIdentifier never sees it.
    final element = node.element;
    _recordIfExtensionMember(element);
    if (_recordClassMembers && element != null && isMemberElement(element)) {
      _recordUsedElement(element);
    }

    super.visitPatternField(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _recordAssignmentTarget(node, node.operand);
    // `a++` reaches `operator +` without naming it.
    _recordMemberUsage(node.element);
    _recordDynamicOperator(node.element, _incrementOperatorName(node.operator));

    super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _recordAssignmentTarget(node, node.operand);
    _recordMemberUsage(node.element);
    _recordDynamicOperator(node.element, _prefixOperatorName(node.operator));

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
          // A prefixed type reference is kept out of `elements`, which is how
          // the unused imports logic this was copied from wants it, but it is
          // still a reference from this library and has to count against the
          // declaration being made private.
          _recordUsageLocality(element);
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
      _recordDynamicWrite(node, target.identifier);
    } else if (target is PropertyAccess) {
      _visitIdentifier(target.propertyName, node.readElement);
      _visitIdentifier(target.propertyName, node.writeElement);
      _recordDynamicWrite(node, target.propertyName);
    } else if (target is SimpleIdentifier) {
      _visitIdentifier(target, node.readElement);
      _visitIdentifier(target, node.writeElement);
      _recordDynamicWrite(node, target);
    } else if (target is IndexExpression) {
      _recordMemberUsage(node.readElement);
      _recordMemberUsage(node.writeElement);
      if (target.inGetterContext()) {
        _recordDynamicOperator(node.readElement, '[]');
      }
      if (target.inSetterContext()) {
        _recordDynamicOperator(node.writeElement, '[]=');
      }
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

  /// Records usage of a member that is reached without an identifier naming it,
  /// such as an operator (`a + b`, `a[b]`, `-a`) or a `call` invocation.
  void _recordMemberUsage(Element? element) {
    _recordIfExtensionMember(element);

    if (!_recordClassMembers || element == null) {
      return;
    }

    // `baseElement` unwraps the member produced by a generic instantiation, so
    // the recorded element is the declaration itself.
    final baseElement = element.baseElement;
    if (isMemberElement(baseElement)) {
      _recordConditionalElement(baseElement);
      _recordUsedElement(baseElement);
    }
  }

  /// Records a member reference on a target of an unknown type by name.
  ///
  /// Such a reference resolves to no element, so there is nothing to record in
  /// [FileElementsUsage.elements], but it can reach any member of that name.
  ///
  /// Callers must not call this for a record field access: a record field
  /// also resolves to no element (records carry no [Element] for their
  /// fields at all), but it is a fully statically typed reference rather than
  /// a dynamic one, so it must not be treated the same way.
  void _recordDynamicUsage(SimpleIdentifier identifier) {
    // A write resolves through the enclosing assignment rather than through
    // the identifier: `host.value = 1` leaves `value.element` null however
    // precisely `host` is typed, so reading a null element here as "reached
    // through a dynamic target" would mark every member named `value` used
    // across the whole program on an ordinary, statically typed assignment.
    // The write half is recorded from `_recordAssignmentTarget` instead,
    // which can tell the two apart. Same reasoning as `visitIndexExpression`.
    if (_recordClassMembers &&
        identifier.element == null &&
        !identifier.inSetterContext()) {
      fileElementsUsage.dynamicallyUsedNames.add(identifier.name);
    }
  }

  /// Records a write to a member of a target of an unknown type.
  ///
  /// The counterpart of [_recordDynamicUsage] for the write half of an
  /// assignment: a null write element on a named target means the assignment
  /// resolved to nothing, so it can reach any setter of that name.
  void _recordDynamicWrite(
    CompoundAssignmentExpression node,
    SimpleIdentifier identifier,
  ) {
    if (_recordClassMembers && node.writeElement == null) {
      fileElementsUsage.dynamicallyUsedNames.add(identifier.name);
    }
  }

  /// Records an operator or `call` reached on a target of an unknown type.
  ///
  /// Mirrors [_recordDynamicUsage] for expressions that reach a member without
  /// an identifier: [name] is the member name the expression reaches (`+`,
  /// `[]=`, `call`), or `null` when the operator is not user-definable (`&&`,
  /// `!`, a plain `=`) and reaches no member at all.
  void _recordDynamicOperator(Element? element, String? name) {
    if (_recordClassMembers && element == null && name != null) {
      fileElementsUsage.dynamicallyUsedNames.add(name);
    }
  }

  /// The member name a binary expression reaches: `a != b` reaches
  /// `operator ==`, every other user-definable operator reaches the member
  /// named by its own lexeme, and the rest (`&&`, `||`, `??`) reach no member.
  static String? _binaryOperatorName(Token operator) {
    if (operator.type == TokenType.BANG_EQ) {
      return '==';
    }

    return operator.type.isUserDefinableOperator ? operator.lexeme : null;
  }

  /// The member name a compound assignment reaches through its combiner:
  /// `a += b` reaches `operator +`. A plain `=` and `??=` reach no member.
  static String? _assignmentOperatorName(Token operator) {
    if (operator.type == TokenType.EQ ||
        operator.type == TokenType.QUESTION_QUESTION_EQ) {
      return null;
    }

    final lexeme = operator.lexeme;

    return lexeme.substring(0, lexeme.length - 1);
  }

  /// The member name a prefix expression reaches: `-a` reaches the unary
  /// minus, whose [Element.name] is `-` just like the binary one (`unary-` is
  /// only its lookup and display name), `~a` reaches `~`, the increments reach
  /// the binary `+`/`-` they desugar to, and `!a` reaches no member.
  static String? _prefixOperatorName(Token operator) {
    if (operator.type == TokenType.MINUS) {
      return '-';
    }
    if (operator.type == TokenType.TILDE) {
      return '~';
    }

    return _incrementOperatorName(operator);
  }

  /// The member name an increment or decrement reaches: `a++` desugars to the
  /// binary `+`, `a--` to the binary `-`. The other postfix operator, the null
  /// assertion `!`, reaches no member.
  static String? _incrementOperatorName(Token operator) {
    if (operator.type == TokenType.PLUS_PLUS) {
      return '+';
    }
    if (operator.type == TokenType.MINUS_MINUS) {
      return '-';
    }

    return null;
  }

  /// Records every constant of [element] as used.
  ///
  /// Called when the enum's `values` is referenced: iteration, `byName` and
  /// name based deserialization all reach the constants without naming any of
  /// them.
  void _recordEnumConstants(EnumElement element) {
    for (final field in element.fields) {
      if (field.isEnumConstant) {
        _recordUsedElement(field);
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
    _recordUsageLocality(element);
  }

  void _recordUsedExtension(ExtensionElement extension) {
    // Remember the element.
    fileElementsUsage.usedExtensions.add(extension);
    _recordUsageLocality(extension);
  }

  /// Remembers [element] as referenced from outside the library that declares
  /// it, which is what rules it out as a candidate for being made private.
  ///
  /// SDK declarations are left out: they are referenced from everywhere and
  /// are never candidates, so keeping them would grow this set by most of
  /// `dart:core` and slow down every lookup against it for nothing.
  void _recordUsageLocality(Element element) {
    if (_recordPrivatizationBlockers &&
        element.library != _library &&
        !_isSdkElement(element)) {
      fileElementsUsage.externallyUsedElements.add(element);
    }
  }

  /// Records every member of [element]'s foreign supertypes that [element]'s
  /// own hierarchy declares somewhere other than on that supertype.
  ///
  /// Such a member cannot be made private without breaking [element]: it is
  /// the override or the interface implementation that would stop lining up
  /// with the supertype's declaration. A member that [element]'s hierarchy
  /// leaves entirely to the supertype is not recorded, since a private member
  /// is still inherited across libraries and keeps working untouched.
  void _recordRedeclaredInheritedMembers(Element? element) {
    if (!_recordPrivatizationBlockers || element is! InterfaceElement) {
      return;
    }

    final supertypes = element.allSupertypes.map((type) => type.element);

    // Which types in this hierarchy declare each member name.
    final declarers = <String, Set<InterfaceElement>>{};
    for (final type in [element, ...supertypes]) {
      for (final name in _declaredMemberNames(type)) {
        declarers.putIfAbsent(name, () => {}).add(type);
      }
    }

    for (final supertype in supertypes) {
      // A supertype from this same library can be privatized freely: the
      // override or implementation sits where the private name is visible.
      // SDK types are never reportable, so walking their members is wasted
      // work on every single class.
      if (supertype.library == _library || _isSdkElement(supertype)) {
        continue;
      }

      // Only what the supertype itself declares can be blocked, so its own
      // member names drive the loop. Each of those names is in `declarers`
      // with at least the supertype in it, which makes a second declarer
      // anywhere in this hierarchy exactly the condition to block on.
      for (final name in _declaredMemberNames(supertype)) {
        if ((declarers[name]?.length ?? 0) > 1) {
          final key = memberKey(supertype, name);
          if (key != null) {
            fileElementsUsage.externallyRedeclaredMembers.add(key);
          }
        }
      }
    }
  }

  Iterable<String> _declaredMemberNames(InterfaceElement element) => [
        ...element.methods.where((member) => !member.isStatic),
        ...element.getters.where((member) => !member.isStatic),
        ...element.setters.where((member) => !member.isStatic),
        ...element.fields.where((member) => !member.isStatic),
      ].map((member) => member.name).nonNulls;

  bool _isSdkElement(Element element) =>
      element.firstFragment.libraryFragment?.source.uri.isScheme('dart') ??
      false;

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
    } else if (_recordClassMembers && enclosingElement is InterfaceElement) {
      _recordUsedElement(element);

      if (element.name == _enumValuesName && enclosingElement is EnumElement) {
        _recordEnumConstants(enclosingElement);
      }
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
