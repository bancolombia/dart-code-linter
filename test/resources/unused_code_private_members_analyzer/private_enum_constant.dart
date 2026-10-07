// A private-named enum constant is scoped like any other private member:
// accessible anywhere in the declaring library, so it is a candidate under
// analyzePrivateMembers, not analyzePublicMembers. See the public-members
// fixture `private_named_enum_constant.dart` for the flag it does not fall
// under.

enum PrivateEnumConstant {
  _unusedConstant,
  usedConstant,
}

PrivateEnumConstant pickUsed() => PrivateEnumConstant.usedConstant;

void main() {
  pickUsed();
}
