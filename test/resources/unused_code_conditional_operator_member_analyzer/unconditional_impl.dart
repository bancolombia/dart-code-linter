class Wrapper {
  Wrapper(this.value);

  final int value;

  Wrapper operator +(Wrapper other) => Wrapper(value + other.value);
}
