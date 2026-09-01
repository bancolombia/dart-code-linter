// Two kinds of member that cannot be renamed at all, whatever the references
// say: an operator has no private spelling, and an enum constant's identifier
// is observable at run time through `name` and `toString`.

enum Season {
  spring,
  summer,
}

class Vector {
  const Vector(this.x);

  final int x;

  Vector operator +(Vector other) => Vector(x + other.x);

  Vector combine(Vector other) => this + other;
}

void main() {
  const Vector(1).combine(const Vector(2));
  Season.spring.toString();
  Season.summer.toString();
}
