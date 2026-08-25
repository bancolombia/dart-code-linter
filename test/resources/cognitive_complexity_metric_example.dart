// ignore_for_file: dead_code, unused_local_variable, no-empty-block

// flat function: three sibling branches, no nesting bonus
void flatFunction(int a) {
  if (a == 1) {
    // +1
  } else if (a == 2) {
    // +1
  } else {
    // +1
  }

  for (var i = 0; i < a; i++) {
    // +1
  }

  final b = a > 0 && a < 10;
}

// nested function: an if inside a for, each nesting level adds its own bonus
void nestedFunction(int a) {
  for (var i = 0; i < a; i++) {
    // +2 (base 1 + nesting level 1)
    if (i == a) {
      // +3 (base 1 + nesting level 2)
      while (i > 0) {
        // +4 (base 1 + nesting level 3)
        i--;
      }
    }
  }
}

// empty function: no branching, cognitive complexity is 0
void emptyFunction() {}

// recursive function: a self-call adds a flat increment
int recursiveFunction(int n) {
  if (n <= 1) {
    // +1
    return 1;
  }

  return n * recursiveFunction(n - 1); // +1 recursion
}
