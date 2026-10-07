import 'package:analyzer/dart/element/element.dart';

/// A container with information about used imports prefixes and used imported
/// elements.
class FileElementsUsage {
  /// The set of referenced top-level elements.
  final Set<Element> elements = {};

  /// The set of extensions defining members that are referenced.
  final Set<ExtensionElement> usedExtensions = {};

  final Set<String> exports = {};

  final Map<Set<String>, Set<Element>> conditionalElements = {};

  final Set<String> conditionalFiles = {};

  /// The map of referenced prefix elements and the elements that they prefix.
  final Map<PrefixElement, List<Element>> prefixMap = {};

  /// The subset of [elements] and [usedExtensions] that is referenced from a
  /// library other than the one declaring them.
  ///
  /// A declaration absent from this set is only ever reached from inside its
  /// own library, which is what makes it a candidate for being made private.
  final Set<Element> externallyUsedElements = {};

  /// Keys, as built by `memberKey`, of members that a type in another library
  /// redeclares somewhere in its own hierarchy.
  ///
  /// Making such a member private silently breaks that subtype: a private
  /// member is inherited across libraries but can no longer be overridden or
  /// implemented there, so dispatch stops reaching the subtype's declaration.
  final Set<String> externallyRedeclaredMembers = {};

  /// The names of members invoked or read on a target of an unknown type.
  ///
  /// Such an invocation resolves to no element at all, so it cannot be recorded
  /// in [elements], but it can reach any member of that name.
  final Set<String> dynamicallyUsedNames = {};

  void merge(FileElementsUsage other) {
    elements.addAll(other.elements);
    usedExtensions.addAll(other.usedExtensions);
    exports.addAll(other.exports);
    conditionalElements.addAll(other.conditionalElements);
    conditionalFiles.addAll(other.conditionalFiles);
    prefixMap.addAll(other.prefixMap);
    dynamicallyUsedNames.addAll(other.dynamicallyUsedNames);
    externallyUsedElements.addAll(other.externallyUsedElements);
    externallyRedeclaredMembers.addAll(other.externallyRedeclaredMembers);
  }
}
