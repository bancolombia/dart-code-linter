// An implementer in another library supplies the interface members that it or
// its own superclasses declare, and every one of those is blocked: a private
// name would compile here and silently stop lining up with the implementation
// over there. Statics are not part of the interface and stay suggestible.
//
// A member the implementer declares nowhere in its hierarchy is not blocked.
// That shape only exists for an abstract implementer, or one answering
// through `noSuchMethod`, where the rename does compile.

class Interface {
  int suppliedByASuperclass() => 1;

  int suppliedByTheImplementer() => 2;

  static int neverInherited() => 3;

  int useEverything() =>
      suppliedByASuperclass() + suppliedByTheImplementer() + neverInherited();
}

void main() {
  Interface().useEverything();
}
