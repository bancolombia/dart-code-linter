// The supertype half of the cross-library override case. Kept in its own
// library on purpose: the name based fallback in `_isEqualElements` only
// matches within a single library, so an override declared here in the same
// file as its subclass would be masked by it rather than by the hierarchy walk.

abstract class Poller {
  void poll();

  void unusedInBase() {}
}
