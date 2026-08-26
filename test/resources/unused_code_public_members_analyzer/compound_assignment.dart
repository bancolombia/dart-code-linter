// The combiner of a resolved compound assignment (`accumulator += 2` reaching
// `operator +`) is a member invocation with no identifier naming it, recorded
// from `AssignmentExpression.element`.
//
// Kept free of other members named `+` or `-`: the name based fallback in
// `_isEqualElements` matches members by name within a library, so a used
// same-named member elsewhere in the file would mask these (note that a used
// *unary* minus masks a binary `-` too, since both have `-` as their
// [Element.name]; `unary-` is only a lookup name).

class Accumulator {
  const Accumulator(this.total);

  final int total;

  /// Used only through `accumulator += 2`.
  Accumulator operator +(int other) => Accumulator(total + other);

  /// Control: never reached, so it is the one member reported.
  Accumulator operator -(int other) => Accumulator(total - other);
}

int useCompoundAssignment() {
  var accumulator = const Accumulator(0);
  accumulator += 2;

  return accumulator.total;
}

void main() {
  useCompoundAssignment();
}
