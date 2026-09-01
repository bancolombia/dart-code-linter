// A write resolves through the enclosing assignment rather than through the
// identifier naming the member, so `target.shared = 1` leaves the identifier's
// element null however precisely `target` is typed. Reading that as "reached
// through a dynamic target" would mark every member named `shared` used
// across the whole program on an ordinary, statically typed assignment.
//
// The members that share these names live in `setter_write_name_twin.dart`,
// in a library of their own: same library name matching would mask them here
// for an unrelated reason.

class WriteTarget {
  set shared(int value) => _stored = value;

  int _stored = 0;

  int read() => _stored;
}

class DynamicWriteTarget {
  set alsoShared(int value) => _stored = value;

  int _stored = 0;
}

void main() {
  WriteTarget()
    ..shared = 1
    ..read();

  final dynamic host = DynamicWriteTarget();
  // ignore: avoid_dynamic_calls
  host.alsoShared = 1;
}
