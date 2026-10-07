// Under `lib/src`, which is off the import surface by convention, so the same
// shape is suggested here in full.

class InternalType {
  int internalMember() => 1;

  int internalCaller() => internalMember();
}

int internalFunction() => InternalType().internalCaller();
