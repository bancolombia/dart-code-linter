// ignore_for_file: prefer_const_constructors

// Every flaggable type declares at least two constructors on purpose: a sole
// private constructor is the prevent-instantiation pattern and is skipped.
// All constructor names are distinct to stay clear of the name+library
// fallback in element matching (see private_override.dart).

class InstanceCreation {
  InstanceCreation._used();

  InstanceCreation._unusedNamed();
}

class FactoryRedirect {
  factory FactoryRedirect() = FactoryRedirect._impl;

  FactoryRedirect._impl();

  FactoryRedirect._unusedInFactoryClass();
}

class GenerativeRedirect {
  GenerativeRedirect() : this._delegate();

  GenerativeRedirect._delegate();

  GenerativeRedirect._unusedInRedirectClass();
}

class SuperBase {
  SuperBase._base();

  SuperBase._unusedInBase();
}

class SuperUser extends SuperBase {
  SuperUser() : super._base();
}

class TearOff {
  TearOff._tearOff();

  TearOff._unusedInTearOffClass();
}

// Sole private constructor: the prevent-instantiation pattern, must NOT be
// reported even though the constructor itself is never invoked.
class StaticOnly {
  StaticOnly._();

  static int answer() => 42;
}

enum SelectorEnum {
  one._select(1);

  const SelectorEnum._select(this.value);

  const SelectorEnum._unusedEnumCtor(this.value);

  final int value;
}

class PublicCtors {
  PublicCtors();

  // Public and unused: must NOT be reported by the private-members analysis.
  PublicCtors.publicUnused();
}

class SuppressedCtor {
  SuppressedCtor();

  // ignore: unused-code
  SuppressedCtor._suppressed();
}

extension type Meters(int value) {
  Meters._unusedSecondary(int raw) : this(raw);
}

int enumValue(SelectorEnum selector) => selector.value;

void main() {
  InstanceCreation._used();
  FactoryRedirect();
  GenerativeRedirect();
  SuperUser();
  const make = TearOff._tearOff;
  make();
  StaticOnly.answer();
  enumValue(SelectorEnum.one);
  PublicCtors();
  SuppressedCtor();
  Meters(5);
}
