// Enum constants reached through `values` and members reached through a call on
// an unknown type carry no reference to the declaration.

enum IteratedStatus {
  first,
  second,
}

enum NamedStatus {
  used,
  unused,
}

class DynamicHost {
  int dynamicallyInvoked() => 1;

  int dynamicallyRead = 3;

  int alsoDynamicallyRead = 4;

  int notInvoked() => 2;
}

int countIterated() => IteratedStatus.values.length;

NamedStatus pickUsed() => NamedStatus.used;

int callDynamically() {
  final dynamic host = DynamicHost();

  // ignore: avoid_dynamic_calls
  return host.dynamicallyInvoked() as int;
}

int readDynamically() {
  final dynamic host = DynamicHost();

  // A member read on a simple identifier of an unknown type: a prefixed
  // identifier rather than a property access.
  // ignore: avoid_dynamic_calls
  return host.dynamicallyRead as int;
}

// A member read on an expression of an unknown type: a property access.
// ignore: avoid_dynamic_calls
int readDynamicallyThroughExpression() =>
    (DynamicHost() as dynamic).alsoDynamicallyRead as int;

void main() {
  countIterated();
  pickUsed();
  callDynamically();
  readDynamically();
  readDynamicallyThroughExpression();
}
