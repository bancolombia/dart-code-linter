import 'external_subclass.dart';

class Derived extends Base {
  // Renaming `Base.redeclaredBySubclass` to a private name would not fail to
  // compile: this would simply stop overriding it, and `callBoth` would
  // silently stop dispatching here.
  @override
  int redeclaredBySubclass() => 3;
}

void main() {
  Derived().callBoth();
}
