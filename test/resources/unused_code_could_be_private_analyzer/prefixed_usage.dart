// Referenced from another library only as a prefixed type, which the usage
// tracking keeps out of its main element set. It is still a reference, and
// the class stays public because of it.

class PrefixedType {
  int member() => 1;
}

PrefixedType makeLocally() => PrefixedType();

void main() {
  makeLocally().member();
}
