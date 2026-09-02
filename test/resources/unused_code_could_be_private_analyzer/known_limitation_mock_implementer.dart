// KNOWN LIMITATION. What this fixture pins is NOT the behavior we want, it is
// the behavior the check has today, recorded so that a change to the
// redeclaration guard shows up as a failing test instead of going unnoticed.
//
// The wrong half is `stubbedByName`. The other library mocks this class by
// hand, answering every call through `noSuchMethod`, so it declares no member
// of its own for the guard to match against. Renaming `stubbedByName` to a
// private name compiles, and the mock then silently stops matching the call,
// because a mock of that shape dispatches on the member name at run time.
//
// The right half is `declaredByTheMock`, the control: a generated style mock
// declares a concrete override, which is exactly what the guard needs to see.
// This is also why mockito's generated mocks are safe and hand written ones
// are not.

class MockedService {
  // Suggested today. It should not be.
  int stubbedByName() => 1;

  // Correctly left alone, because the mock over there declares it.
  int declaredByTheMock() => 2;

  int caller() => stubbedByName() + declaredByTheMock();
}

void main() {
  MockedService().caller();
}
