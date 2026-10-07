class Api {
  int usedField = 1;

  int unusedField = 2;

  int get usedGetter => usedField;

  int get unusedGetter => 3;

  set usedSetter(int value) => usedField = value;

  set unusedSetter(int value) => usedField = value;

  int usedMethod() => usedGetter;

  int unusedMethod() => 4;

  static int usedStatic() => 5;

  static int unusedStatic() => 6;

  // Private and unused: must NOT be reported by the public members analysis.
  int _privateUnusedMethod() => 7;

  // The unnamed constructor is never a candidate: its invocations carry no
  // identifier for the usage visitor to record.
  Api();

  Api.usedNamed();

  Api.unusedNamed();
}

void main() {
  final api = Api.usedNamed()
    ..usedSetter = 1
    ..usedMethod();

  if (api.usedGetter > 0) {
    Api.usedStatic();
  }

  Api();
}
