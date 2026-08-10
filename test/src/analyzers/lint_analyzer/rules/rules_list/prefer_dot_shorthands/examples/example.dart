// @dart=3.10

enum LogLevel { info, warning, error }

class Point {
  const Point(this.x, this.y);
  const Point.origin() : this(0, 0);

  final int x;
  final int y;

  static Point zero() => const Point(0, 0);
}

void logMessage(String message, {required LogLevel level}) {}

void positionalArgument(LogLevel level) {}

// Flagged: named argument, type matches the parameter's declared type.
void useNamedArgument() {
  logMessage('failed', level: LogLevel.error);
}

// Flagged: positional argument.
void usePositionalArgument() {
  positionalArgument(LogLevel.warning);
}

// Flagged: explicitly typed variable declaration.
void useVariableDeclaration() {
  LogLevel level = LogLevel.info;
  print(level);
}

// Flagged: named constructor call matching the parameter type.
void useNamedConstructor() {
  acceptPoint(Point.origin());
}

// Flagged: static method call matching the parameter type.
void useStaticMethod() {
  acceptPoint(Point.zero());
}

void acceptPoint(Point point) {}

// Not flagged: no explicit type annotation, type is inferred from the RHS.
void noExplicitVariableType() {
  final level = LogLevel.info;
  print(level);
}

// Not flagged: argument type doesn't match the accessed type.
void mismatchedArgument() {
  print(LogLevel.info);
}

// Not flagged: unnamed constructor call (kept verbose to avoid `.new` ambiguity).
void unnamedConstructorCall() {
  acceptPoint(Point(1, 2));
}

class ValueNotifier<T> {
  ValueNotifier(T value);
}

T identity<T>(T value) => value;

// Not flagged: the parameter is declared as a type parameter, so its type is
// inferred from this very argument; a shorthand would have no context type.
void inferredGenericArguments() {
  print(ValueNotifier(LogLevel.info));
  print(identity(LogLevel.error));
}

// Not flagged: an explicit const keeps the constructor call as-is.
void constKeywordCall() {
  acceptPoint(const Point.origin());
}

class Box<T> {
  Box.empty();
}

void acceptBox(Box<int> box) {}

// Not flagged: explicit type arguments on a named constructor call.
void explicitConstructorTypeArguments() {
  acceptBox(Box<int>.empty());
}

class Maker {
  static Maker create<T>() => Maker();
}

void acceptMaker(Maker maker) {}

// Not flagged: explicit type arguments on a static method call.
void explicitMethodTypeArguments() {
  acceptMaker(Maker.create<int>());
}

// Not flagged: the parameter type is a supertype of the accessed type, so a
// dot shorthand would not resolve against it.
void supertypeParameter() {
  acceptObject(LogLevel.info);
}

void acceptObject(Object value) {}
