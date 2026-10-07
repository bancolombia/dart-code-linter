// A member of a type the same run reports as dead code is not a rename
// candidate: the answer for the whole type is to delete it, not to privatize
// its members one by one.
//
// Such a member only looks used at all because of the deliberately loose same
// library name fallback that works around dart-lang/sdk#49182. The live
// `sharedName` on line 14 is what it matches.

class NeverReferenced {
  int sharedName() => 1;
}

class Referenced {
  int sharedName() => 2;

  int caller() => sharedName();
}

void main() {
  Referenced().caller();
}
