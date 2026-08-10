sealed class Shape {}

class Circle extends Shape {}

class Square extends Shape {}

class NotSealed {}

String describeStatementWithDefault(Shape shape) {
  switch (shape) {
    case Circle():
      return 'circle';
    default:
      return 'unknown';
  }
}

String describeStatementWithWildcard(Shape shape) {
  switch (shape) {
    case Circle():
      return 'circle';
    case _:
      return 'unknown';
  }
}

String describeExpressionWithWildcard(Shape shape) => switch (shape) {
      Circle() => 'circle',
      _ => 'unknown',
    };

String describeStatementExhaustive(Shape shape) {
  switch (shape) {
    case Circle():
      return 'circle';
    case Square():
      return 'square';
  }
}

String describeExpressionExhaustive(Shape shape) => switch (shape) {
      Circle() => 'circle',
      Square() => 'square',
    };

String describeNotSealedWithDefault(NotSealed value) {
  switch (value) {
    default:
      return 'unknown';
  }
}

// A guarded wildcard doesn't satisfy exhaustiveness, so the compiler still
// requires the remaining subtypes to be covered; there is no fallback to flag.
String describeStatementWithGuardedWildcard(Shape shape, bool flag) {
  switch (shape) {
    case Circle():
      return 'circle';
    case _ when flag:
      return 'flagged';
    case Square():
      return 'square';
  }
}

String describeExpressionWithGuardedWildcard(Shape shape, bool flag) =>
    switch (shape) {
      Circle() => 'circle',
      _ when flag => 'flagged',
      Square() => 'square',
    };
