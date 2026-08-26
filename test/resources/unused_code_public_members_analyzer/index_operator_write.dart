// A statically typed index write like `list[0] = 1` resolves through a
// separate analyzer path (`resolveForWrite`) that, unlike an index read,
// never populates `IndexExpression.element`. Recording usage from that null
// element the same way a genuinely dynamic target is handled would mark
// `operator []=` reached everywhere in the program, hiding every dead one -
// including `Dead.operator []=` below, which nothing ever calls.

class Dead {
  int value = 0;

  void operator []=(int index, int newValue) {
    value = newValue;
  }
}

void writeIndex() {
  // A plain, statically typed write on an unrelated `List`: it is the write
  // itself that must not exempt `Dead.operator []=`, not any relation
  // between the two.
  final list = <int>[1, 2, 3];
  list[0] = 4;

  Dead();
}

void main() {
  writeIndex();
}
