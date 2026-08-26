import 'package:analyzer/dart/element/element.dart';

/// Whether [element] is declared inside a type or an extension rather than
/// at the library level.
bool isMemberElement(Element? element) {
  final enclosingElement = element?.enclosingElement;

  return enclosingElement is InterfaceElement ||
      enclosingElement is ExtensionElement;
}
