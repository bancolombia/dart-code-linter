// A foreign subtype blocks the members it redeclares whatever declaration
// kind carries the supertype edge: a mixin's `on` constraint, a mixin
// application written as a class type alias, an enum's `implements` and an
// extension type's `implements`, none of which is a class declaration.
//
// The members the other library never mentions stay suggestible, since a
// private member is inherited across libraries and keeps working untouched.

class MixinHost {
  int mixedRedeclared() => 1;

  int mixedUntouched() => 2;

  int callMixed() => mixedRedeclared() + mixedUntouched();
}

class AliasHost {
  int aliasRedeclared() => 3;

  int aliasUntouched() => 4;

  int callAlias() => aliasRedeclared() + aliasUntouched();
}

// An implementer has to supply every member of the interface, so this one
// carries a single instance member. The static is the control: statics are
// never inherited, so no implementer can redeclare one.
class EnumInterface {
  int enumRedeclared() => 5;

  static int enumNeverInherited() => 6;
}

int callEnumInterface() =>
    EnumInterface().enumRedeclared() + EnumInterface.enumNeverInherited();

class ExtensionTypeHost {
  int wrappedRedeclared() => 7;

  int wrappedUntouched() => 8;

  int callWrapped() => wrappedRedeclared() + wrappedUntouched();
}

void main() {
  MixinHost().callMixed();
  AliasHost().callAlias();
  callEnumInterface();
  ExtensionTypeHost().callWrapped();
}
