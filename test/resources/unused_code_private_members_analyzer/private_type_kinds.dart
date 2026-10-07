// Covers every type declaration kind that `PublicCodeVisitor` descends into
// besides plain classes and extensions, plus static members and a member level
// `// ignore: unused-code` suppression.

mixin PrivateMixinMembers {
  int _usedInMixin() => 1;

  int _unusedInMixin() => 2;
}

class MixinUser with PrivateMixinMembers {
  int use() => _usedInMixin();
}

enum PrivateEnumMembers {
  first,
  second;

  static const int _usedStaticInEnum = 1;

  static const int _unusedStaticInEnum = 2;

  int get _usedEnumGetter => index + _usedStaticInEnum;

  int get _unusedEnumGetter => index;

  int _unusedEnumMethod() => 0;

  int describe() => _usedEnumGetter;
}

extension type PrivateExtensionTypeMembers(int value) {
  int get _usedInExtensionType => value;

  int get _unusedInExtensionType => value + 1;

  int describe() => _usedInExtensionType;
}

class PrivateStaticMembers {
  static const int _usedStaticConst = 1;

  static const int _unusedStaticConst = 2;

  static int _usedStaticMethod() => _usedStaticConst;

  static int _unusedStaticMethod() => 3;

  static int get _unusedStaticGetter => 4;

  int use() => _usedStaticMethod();
}

class SuppressedMember {
  // ignore: unused-code
  int _suppressedUnusedMethod() => 1;

  int _reportedUnusedMethod() => 2;

  int describe() => 0;
}

void main() {
  MixinUser().use();
  PrivateEnumMembers.first.describe();
  PrivateExtensionTypeMembers(1).describe();
  PrivateStaticMembers().use();
  SuppressedMember().describe();
}
