// Dead members whose names `non_writing_operators.dart` applies a prefix or
// postfix operator to.

class UnrelatedToTheOperators {
  // Reported: every operator over there is statically resolved, so none of
  // them says anything about a member of that name declared here.
  bool negated = false;

  int? asserted;

  int negatedNumber = 0;

  int complemented = 0;
}

class UnrelatedToTheDynamicOperator {
  // Not reported: the negation over there is applied to a member of a dynamic
  // target, which resolves to nothing at all, so it could be reaching this
  // member.
  bool dynamicallyNegated = false;
}

void main() {
  UnrelatedToTheOperators();
  UnrelatedToTheDynamicOperator();
}
