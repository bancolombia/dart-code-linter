// Kept in its own library on purpose: the name based fallback in
// `_isEqualElements` only matches within a single library, so a same-named
// static and instance member declared in the same file as each other would
// be masked by that fallback rather than by the supertype name collection
// this fixture actually exercises.

class Base {
  static void log(String message) {}
}
