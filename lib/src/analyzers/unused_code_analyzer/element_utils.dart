import 'package:analyzer/dart/element/element.dart';

/// A key identifying the member named [memberName] declared by [type], stable
/// across analysis contexts.
///
/// Element identity cannot be relied on here: the same declaration analyzed
/// through two different contexts of a monorepo yields two unequal elements,
/// which is the same problem element comparison has elsewhere in this
/// analyzer. Keying on the declaring file plus the two names is stable and
/// errs towards over-matching, which for the privatization blockers this
/// builds can only cost a suggestion, never correctness.
String? memberKey(Element type, String? memberName) {
  final path = type.firstFragment.libraryFragment?.source.fullName;
  final typeName = type.name;

  return path == null || typeName == null || memberName == null
      ? null
      : '$path::$typeName::$memberName';
}

/// Whether [element] is declared inside a type or an extension rather than
/// at the library level.
bool isMemberElement(Element? element) {
  final enclosingElement = element?.enclosingElement;

  return enclosingElement is InterfaceElement ||
      enclosingElement is ExtensionElement;
}
