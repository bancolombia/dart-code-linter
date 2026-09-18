// With the public members check enabled alongside, a dead member is reported
// as unused and never also as a rename candidate. With the suggestions alone,
// it is not reported at all: dead code is the other flag's verdict.

class Precedence {
  int usedLocally() => 1;

  int neverUsed() => 2;

  int caller() => usedLocally();
}

void main() {
  Precedence().caller();
}
