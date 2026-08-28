// ignore_for_file: unused_local_variable, no-empty-block

// Fixtures for the individual scoring rules of SonarSource's Cognitive
// Complexity specification (white paper v1.7, Appendix B). Each function is
// annotated with the increment the specification assesses for every structure,
// so the expected totals in the tests can be checked against the paper.

// B1 switch: "A switch and all its cases combined incurs a single structural
// increment", and the cases raise the nesting level for what they contain.
String switchStatement(int number) {
  switch (number) {
    // +1
    case 1:
      return 'one';
    case 2:
      return 'a couple';
    default:
      if (number > 3) {
        // +2 (base 1 + nesting 1)
        return 'lots';
      }

      return 'a few';
  }
}

// B1 catch: "each catch clause results in a structural increment [...] try and
// finally blocks are ignored altogether".
void catchClauses(int a) {
  try {
    if (a > 0) {} // +1 (try does not raise the nesting level)
  } on StateError {
    // +1
    if (a > 0) {} // +2 (base 1 + nesting 1)
  } catch (e) {
    // +1
    if (a > 0) {} // +2 (base 1 + nesting 1)
  } finally {
    if (a > 0) {} // +1 (finally does not raise the nesting level)
  }
}

// B3 ternary operator: subject to a nesting increment like an if.
int ternaryOperator(int a) => a > 0
    ? a > 5
        ? 1 // the inner ternary is +2 (base 1 + nesting 1)
        : 2
    : 3; // the outer ternary is +1

// B1 jumps to labels, taken verbatim from the white paper's canonical example.
// The paper scores this function at 7.
int sumOfPrimes(int max) {
  var total = 0;

  outer:
  for (var i = 1; i <= max; ++i) {
    // +1
    for (var j = 2; j < i; ++j) {
      // +2 (base 1 + nesting 1)
      if (i % j == 0) {
        // +3 (base 1 + nesting 2)
        continue outer; // +1 (a labeled jump, never a nesting increment)
      }
    }
    total += i;
  }

  return total;
}

// "no other jumps or early exits cause an increment": unlabeled break,
// unlabeled continue and return are free.
void unlabeledJumps(List<int> numbers) {
  for (final number in numbers) {
    // +1
    if (number < 0) {
      // +2 (base 1 + nesting 1)
      continue; // +0
    }
    if (number > 10) {
      // +2 (base 1 + nesting 1)
      break; // +0
    }
  }

  return; // +0
}

// B2 "nested methods and method-like structures such as lambdas" raise the
// nesting level without being scored themselves.
void closureNesting(List<int> numbers) {
  numbers.forEach((number) {
    // +0, but the nesting level is now 1
    if (number > 0) {} // +2 (base 1 + nesting 1)
  });
}

void closureInsideLoop(List<int> numbers) {
  for (final number in numbers) {
    // +1
    numbers.forEach((other) {
      // +0, but the nesting level is now 2
      if (other > 0) {} // +3 (base 1 + nesting 2)
    });
  }
}

// Hybrid increments: else and else if are scored +1 with no nesting increment
// of their own, "but which do increase the nesting count" for their bodies.
void elseIfChain(int a) {
  if (a == 1) {
    // +1
    if (a == 1) {} // +2 (base 1 + nesting 1)
  } else if (a == 2) {
    // +1 (hybrid: no nesting increment)
    if (a == 2) {} // +2 (base 1 + nesting 1)
  } else {
    // +1 (hybrid: no nesting increment)
    if (a == 3) {} // +2 (base 1 + nesting 1)
  }
}

// "Cognitive complexity increments for each new sequence of like operators".
// Both conditions below are taken verbatim from the white paper, which scores
// the first at 4 and the second at 3:
//
//   if (a          // +1 for `if`
//       && b && c  // +1
//       || d || e  // +1
//       && f)      // +1
//
//   if (a          // +1 for `if`
//       &&         // +1
//       !(b && c)) // +1
bool mixedOperatorSequences(bool a, bool b, bool c, bool d, bool e, bool f) {
  if (a && b && c || d || e && f) {
    return true;
  }

  return false;
}

bool negatedOperatorSequence(bool a, bool b, bool c) {
  if (a && !(b && c)) {
    return true;
  }

  return false;
}

// A sequence of like operators outside a condition is still scored: the paper
// increments "for all sequences of binary boolean operators such as those in
// variable assignments, method invocations, and return statements".
bool operatorSequenceInReturn(bool a, bool b, bool c) => a && b && c; // +1

// Dart's collection-literal `if` and `for` are the same control flow structures
// as their statement forms, so Appendix B assesses increments for them. The
// visitor does not score them today, and this fixture pins that gap.
List<int> collectionLiteralControlFlow(List<int> numbers, bool flag) => [
      for (final number in numbers) // expected +1, scored 0 today
        if (number > 0) number, // expected +2, scored 0 today
      if (flag) 0, // expected +1, scored 0 today
    ];

// Dart 3 switch expressions are switches, so Appendix B assesses an increment
// for them. The visitor does not score them today, and this fixture pins that
// gap.
String switchExpression(int number) => switch (number) {
      1 => 'one', // expected +1 for the switch as a whole, scored 0 today
      2 => 'a couple',
      _ => 'lots',
    };

// A pattern `if-case` with a `when` guard. The guard's operator sequence is
// expected to be scored, but the visitor never walks the case clause today.
void ifCaseGuard(Object value) {
  if (value case int number when number > 0 && number < 10) {
    // +1 for the if, and the `&&` sequence is expected to add +1
    final matched = number;
  }
}

// Two recursive call sites in the same method. The specification assesses a
// fundamental increment "for each method in a recursion cycle", not for each
// call, so the expected score is one increment.
int fibonacci(int n) {
  if (n < 2) {
    // +1
    return n;
  }

  return fibonacci(n - 1) + fibonacci(n - 2); // expected +1 for the cycle
}

// Recursion through an explicit `this` receiver.
class Recursive {
  int factorial(int n) {
    if (n <= 1) {
      // +1
      return 1;
    }

    return n * this.factorial(n - 1); // expected +1 for the cycle
  }
}
