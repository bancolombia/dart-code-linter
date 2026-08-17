// Regression fixture: an operator usage, which is reached without naming it
// with an identifier, must still be recorded as a conditional-import
// candidate through `_recordConditionalElement`, the same way an ordinary
// identifier usage is. Otherwise the identical declaration in this file's
// unselected sibling, `unconditional_impl.dart`, is never bridged and is
// falsely reported as unused.

class Wrapper {
  Wrapper(this.value);

  final int value;

  Wrapper operator +(Wrapper other) => Wrapper(value + other.value);
}
