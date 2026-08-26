// The tool's own analysis pipeline resolves files normally even when they
// carry compile errors, so a class whose own supertype fails to resolve
// (here, `MissingBase` is simply never declared) is exercised like any other
// file. See `_hasUnresolvedHierarchyClause` in public_code_visitor.dart.

class Derived extends MissingBase {
  // Unannotated: it looks exactly like an override of whatever
  // `MissingBase` declares, which cannot be seen since `MissingBase` itself
  // failed to resolve. Must not be reported.
  void template() {}

  // Unrelated to any hypothetical override and never referenced anywhere.
  // Also exempted: once a type's hierarchy fails to resolve, none of its
  // members can be told apart from a possible override, so the whole type
  // is treated as reachable without reference. The accepted trade-off is a
  // missed detection here rather than a false positive on `template`.
  void unrelated() {}
}

void main() {
  Derived();
}
