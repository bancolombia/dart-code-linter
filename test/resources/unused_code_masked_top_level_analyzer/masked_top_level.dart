// Regression fixture: recording member usages must not mask dead top level
// declarations that happen to share a name with a used member of the same
// library. `_isEqualElements` falls back to name plus library matching (a
// workaround for https://github.com/dart-lang/sdk/issues/49182), and that
// fallback must not cross the member / library level boundary.
//
// This fixture lives in its own folder because its top level declarations are
// reported regardless of the member analysis flag, which would break the
// "no reports when disabled" expectation of the private members folder.

/// Never referenced anywhere: must be reported even though `Resettable.reset`
/// is used below and carries the same name.
void reset() {}

/// Never referenced anywhere: must be reported even though
/// `Resettable.counter` is read below and carries the same name.
int counter = 0;

class Resettable {
  int counter = 0;

  void reset() {
    counter = 0;
  }
}

void main() {
  final resettable = Resettable()..reset();

  if (resettable.counter > 0) {
    resettable.reset();
  }
}
