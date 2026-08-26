// Operators invoked on a `dynamic` target resolve to no element, exactly like
// dynamic method calls and property reads do, so the usage is recorded by the
// member name the expression reaches (`~/`, `[]=`, `-`, `call`) into
// `FileElementsUsage.dynamicallyUsedNames`.
//
// Every operator below is reached through a different expression kind, so each
// recording path is pinned separately. The operators are picked so that no two
// expression kinds map to the same member name (`host++` and `host - 1` would
// both record `+`/`-`).
//
// This fixture lives in its own folder on purpose: dynamically used names are
// matched program-wide, so the `~host` below would mark every `operator ~` in
// the analyzed folder as used and silently defuse the `~` control member of
// the unary_operators.dart fixture.
//
// ignore_for_file: avoid_dynamic_calls

class DynamicTarget {
  int value = 0;

  /// Reached by the binary expression `host ~/ 2`.
  DynamicTarget operator ~/(int other) => this;

  /// Reached by the postfix increment `host++`, which desugars to the
  /// binary `+`.
  DynamicTarget operator +(int other) => this;

  /// Reached by the compound assignment `host *= 2` through its combiner.
  DynamicTarget operator *(int other) => this;

  /// Reached by the prefix expression `-host`. The member's [Element.name] is
  /// `-`, the same as a binary minus; `unary-` is only its lookup name.
  DynamicTarget operator -() => this;

  /// Reached by the prefix expression `~host`.
  DynamicTarget operator ~() => this;

  /// Reached by the index read `host[0]`.
  int operator [](int index) => value;

  /// Reached by the index write `host[0] = 1`.
  void operator []=(int index, int newValue) {
    value = newValue;
  }

  /// Reached by the implicit invocation `host(1)`.
  int call(int input) => input;

  /// Control: never reached, so it is the one member reported. Without it a
  /// regression that skips operator candidates wholesale would keep this file
  /// green.
  DynamicTarget operator %(int other) => this;
}

List<Object?> useDynamically() {
  dynamic host = DynamicTarget();

  final results = <Object?>[host ~/ 2, -host, ~host, host[0], host(1)];

  host[0] = 1;
  host++;
  host *= 2;

  return results;
}

void main() {
  useDynamically();
}
