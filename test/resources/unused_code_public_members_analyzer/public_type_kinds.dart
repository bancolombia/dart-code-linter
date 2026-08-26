// Public members of every type declaration kind besides plain classes, plus a
// suppressed enum constant.

import 'package:meta/meta.dart';

mixin PublicMixinMembers {
  int usedInMixin() => 1;

  int unusedInMixin() => 2;
}

class MixinUser with PublicMixinMembers {
  int use() => usedInMixin();
}

enum PublicEnumMembers {
  first,
  second,
  // ignore: unused-code
  suppressedConstant;

  int usedEnumMethod() => index;

  int unusedEnumMethod() => 0;
}

extension type PublicExtensionTypeMembers(int value) implements int {
  int get usedInExtensionType => value;

  int get unusedInExtensionType => value + 1;

  // Redeclares `int.abs`, so callers reach it through the `int` interface.
  @redeclare
  int abs() => value;
}

int useMixin() => MixinUser().use();

int useEnum() => PublicEnumMembers.first.usedEnumMethod();

int useExtensionType() => PublicExtensionTypeMembers(1).usedInExtensionType;

void main() {
  useMixin();
  useEnum();
  useExtensionType();
}
