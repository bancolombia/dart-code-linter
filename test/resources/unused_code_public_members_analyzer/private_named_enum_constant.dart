// A private-named enum constant is scoped like any other private member of
// the enum, not a special "always public" case: it is a candidate under
// analyzePrivateMembers, not analyzePublicMembers. See the private-members
// fixture `private_enum_constant.dart` for the flag it actually falls under.

enum PublicEnumConstant {
  _unusedPrivateConstant,
  usedPublicConstant,
}

PublicEnumConstant pickUsed() => PublicEnumConstant.usedPublicConstant;

void main() {
  pickUsed();
}
