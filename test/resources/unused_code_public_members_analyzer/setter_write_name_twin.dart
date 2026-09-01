// Two dead members whose names `setter_write_resolution.dart` writes.

class UnrelatedToTheWrite {
  // Reported: the write of `shared` over there is statically resolved, so it
  // says nothing about a member of that name declared here.
  int shared() => 1;
}

class UnrelatedToTheDynamicWrite {
  // Not reported: the write of `alsoShared` over there resolves to nothing at
  // all, so it could be reaching this member.
  int alsoShared() => 2;
}

void main() {
  UnrelatedToTheWrite();
  UnrelatedToTheDynamicWrite();
}
