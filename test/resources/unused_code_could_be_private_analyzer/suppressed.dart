// The suggestions answer to the same `unused-code` ignore comment as the
// unused verdict does, both on a member and on a whole file.

class Suppressed {
  // ignore: unused-code
  int suppressedMember() => 1;

  int reportedMember() => 2;

  int callBoth() => suppressedMember() + reportedMember();
}

void main() {
  Suppressed().callBoth();
}
