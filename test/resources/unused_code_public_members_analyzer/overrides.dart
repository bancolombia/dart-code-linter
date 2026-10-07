// Members that override or implement an inherited member are reached through
// dispatch on the supertype, so no recorded usage ever points at them.

abstract class Base {
  void template();

  void hook() {}

  void unusedInBase() {}
}

class Derived extends Base {
  @override
  void template() {}

  // An override without the annotation: dispatch on `Base.hook` resolves to
  // Base's declaration, so this must not be reported either.
  // ignore: annotate_overrides
  void hook() {}

  void derivedUsed() {}

  void derivedUnused() {}
}

void main() {
  final Base base = Derived()..derivedUsed();

  base
    ..template()
    ..hook();
}
