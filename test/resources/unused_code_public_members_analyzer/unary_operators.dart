// Unary operators and increments reach a member without naming it, exactly like
// binary operators and index reads do. Kept in its own library so the name based
// fallback in `_isEqualElements` cannot mask an operator through a same-named
// operator of another class.

class Counter {
  const Counter(this.value);

  final int value;

  Counter operator -() => Counter(-value);

  Counter operator ~() => Counter(~value);

  Counter operator +(int other) => Counter(value + other);
}

int useUnaryMinus() => (-const Counter(1)).value;

int useIncrement() {
  var counter = const Counter(1);
  counter++;

  return counter.value;
}

void main() {
  useUnaryMinus();
  useIncrement();
}
