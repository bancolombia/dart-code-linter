// KNOWN LIMITATION FIXTURE (see the note on _PrivateMemberVisitor in
// public_code_visitor.dart): privacy is library-scoped, not class-scoped, so
// a private member can be overridden across classes in the same library.
// Usage tracking does not currently guard against this; the two hierarchies
// below pin down the actual (imperfect) current behavior so a future change
// to the equality matching in unused_code_analyzer.dart doesn't silently
// flip it into a false positive without anyone noticing.

abstract class Base {
  void _template();
}

class Derived extends Base {
  @override
  void _template() {}
}

class Base2 {
  void _template2() {}
}

// Instantiated below, but _template2 is never called on it: the override
// itself is genuinely dead code, though it is not currently reported (see
// the test for why).
class Derived2 extends Base2 {
  @override
  void _template2() {}
}

void main() {
  final Base instance = Derived();
  instance._template();

  Base2()._template2();

  Derived2();
}
