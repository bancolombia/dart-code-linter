// A subclass in the same library blocks nothing: the override sits where a
// private name is still visible, so both declarations can be renamed together.

class LocalBase {
  int overriddenLocally() => 1;

  int callIt() => overriddenLocally();
}

class LocalDerived extends LocalBase {
  @override
  int overriddenLocally() => 2;
}

void main() {
  LocalDerived().callIt();
}
