import 'static_name_collision_base.dart';

class Derived extends Base {
  // A same-named, but unrelated, instance method: statics are never
  // inherited, so this is not an override of `Base.log` and dispatch on
  // `Base` never reaches it.
  void log() {}
}

void main() {
  Base.log('hi');
  Derived();
}
