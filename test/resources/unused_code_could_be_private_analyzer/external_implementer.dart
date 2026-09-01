// An implementer in another library has to supply every member of the
// interface, and cannot supply one with a private name, so nothing on the
// instance surface of this class can be renamed. Statics are not part of the
// interface and stay suggestible.

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
