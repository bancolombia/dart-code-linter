// A subclass in another library only blocks the members it redeclares. A
// private member is still inherited across libraries and keeps working, so a
// member the subclass never mentions can be renamed freely.

class Base {
  int untouchedBySubclass() => 1;

  int redeclaredBySubclass() => 2;

  int callBoth() => untouchedBySubclass() + redeclaredBySubclass();
}

void main() {
  Base().callBoth();
}
