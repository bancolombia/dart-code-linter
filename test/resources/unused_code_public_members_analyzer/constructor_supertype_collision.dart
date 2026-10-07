import 'constructor_supertype_collision_base.dart';

class Derived extends Base {
  // A named constructor, not an instance method: constructors and instance
  // members occupy separate namespaces, so this is not declared by `Base` in
  // any sense that dispatch on `Base` could reach, even though it shares a
  // name with `Base.build`.
  Derived.build();
}

void main() {
  Base().build();
  Derived();
}
