// A prefix or postfix operator that performs no write still resolves through
// `_recordAssignmentTarget`, where the enclosing expression's `writeElement`
// is null simply because there is no write. Reading that as "reached through
// a dynamic target" would mark every member of these names used across the
// whole program on an ordinary, statically typed `!x`, `x!`, `-x` or `~x`.
//
// The members that share these names live in
// `non_writing_operators_name_twin.dart`, in a library of their own: same
// library name matching would mask them here for an unrelated reason.

class OperatorTarget {
  bool negated = false;

  int? asserted;

  int negatedNumber = 0;

  int complemented = 0;
}

class DynamicOperatorTarget {
  bool dynamicallyNegated = false;
}

void main() {
  final target = OperatorTarget();
  print(!target.negated);
  print(target.asserted!);
  print(-target.negatedNumber);
  print(~target.complemented);

  final dynamic host = DynamicOperatorTarget();
  // The one genuinely unresolved case: it can reach any member of that name.
  // ignore: avoid_dynamic_calls
  print(!host.dynamicallyNegated);
}
