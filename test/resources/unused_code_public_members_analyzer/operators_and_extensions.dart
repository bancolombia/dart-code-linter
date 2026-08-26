// Operator and `call` invocations reach a member without naming it, so they are
// recorded from the expression rather than from an identifier.

class Vector {
  final int value;

  const Vector(this.value);

  Vector operator +(Vector other) => Vector(value + other.value);

  Vector operator *(Vector other) => Vector(value * other.value);

  int operator [](int index) => value + index;

  @override
  bool operator ==(Object other) => other is Vector && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Callable {
  int call(int input) => input;
}

extension PublicIntExtension on int {
  int get doubled => this * 2;

  int get tripled => this * 3;
}

int useOperators() {
  const first = Vector(1);
  const second = Vector(2);
  final sum = first + second;

  return sum[0];
}

int useCallable() => Callable()(1);

int useExtension() => 1.doubled;

class Wrapper {
  int value = 0;
}

extension WrapperMath on Wrapper {
  Wrapper operator +(int other) => this..value += other;
}

// `wrapper += 1` reaches the extension's `operator +` only through the
// compound assignment's combiner. Both the member and the extension itself
// are only marked used through it.
Wrapper useExtensionCompound() {
  var wrapper = Wrapper();
  wrapper += 1;

  return wrapper;
}

void main() {
  useOperators();
  useCallable();
  useExtension();
  useExtensionCompound();
}
