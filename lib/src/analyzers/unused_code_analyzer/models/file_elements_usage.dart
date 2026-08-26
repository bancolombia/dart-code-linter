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
  }
}
