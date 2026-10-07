// Kept in its own library on purpose, mirroring `static_name_collision_base.dart`:
// the name based fallback in `_isEqualElements` only matches within a single
// library, so a same-file placement would be masked by that fallback rather
// than by the supertype name collection this fixture actually exercises.

class Base {
  void build() {}
}
