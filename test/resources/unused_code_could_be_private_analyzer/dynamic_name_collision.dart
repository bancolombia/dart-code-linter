// An invocation on a target of an unknown type can come from anywhere,
// including another library, so a member sharing that name cannot be shown to
// be library local.

class DynamicHost {
  int shared() => 1;

  int notShared() => 2;

  int callBoth() => shared() + notShared();
}

void main() {
  final dynamic host = DynamicHost();
  // ignore: avoid_dynamic_calls
  host.shared();

  DynamicHost().callBoth();
}
