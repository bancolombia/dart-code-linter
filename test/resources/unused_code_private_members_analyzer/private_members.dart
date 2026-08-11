// ignore_for_file: prefer_const_constructors

class SomeClass {
  final int _usedField = 1;

  // Used only via an object pattern in `main`: must NOT be reported.
  final int _patternUsedField = 6;

  final int _unusedField = 2;

  int _usedMethod() => _usedField;

  int _unusedMethod() => 3;

  int get _usedGetter => _usedField;

  int get _unusedGetter => 4;

  int _setterBackingField = 0;

  set _usedSetter(int value) => _setterBackingField = value;

  set _unusedSetter(int value) => _setterBackingField = value;

  int publicUsedMethod() => _usedMethod() + _usedGetter;

  // Public and unused: must NOT be reported by the private-members analysis.
  int publicUnusedMethod() => 5;
}

extension IntPrivateMembersExtension on int {
  int get _usedExtensionGetter => this;

  int get _unusedExtensionGetter => this;

  int _usedExtensionMethod() => _usedExtensionGetter;

  int _unusedExtensionMethod() => 3;
}

void main() {
  final instance = SomeClass();
  instance.publicUsedMethod();
  instance._usedSetter = 10;

  1._usedExtensionMethod();

  if (instance case SomeClass(_patternUsedField: > 0)) {
    instance.publicUsedMethod();
  }
}
