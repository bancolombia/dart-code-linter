# Worked examples

Every score below was produced by the implementation, not computed by hand. Most
of the code is drawn from
[`test/resources/cognitive_complexity_rules_example.dart`](../../test/resources/cognitive_complexity_rules_example.dart)
and
[`test/resources/cognitive_complexity_metric_example.dart`](../../test/resources/cognitive_complexity_metric_example.dart),
reformatted to put each increment on the line it applies to, so any of these can
be re-measured by running the metric tests.

## The calibration pair

The two functions the white paper uses to show why Cyclomatic Complexity is the
wrong tool for readability. The paper reports a Cyclomatic Complexity of 4 for
both.

### `sumOfPrimes`, cognitive 7

```dart
int sumOfPrimes(int max) {
  var total = 0;

  outer:
  for (var i = 1; i <= max; ++i) {     // +1
    for (var j = 2; j < i; ++j) {      // +2  (1 + nesting 1)
      if (i % j == 0) {                // +3  (1 + nesting 2)
        continue outer;                // +1  (labeled jump, never nested)
      }
    }
    total += i;
  }

  return total;
}
```

This is the paper's own example, and 7 is its published value. It is the single
most useful regression check in the suite: it exercises loop nesting, a nesting
increment two levels deep, and the labeled-jump rule at once.

### `getWords`, cognitive 1

```dart
String getWords(int number) {
  switch (number) {   // +1, and that is the whole score
    case 1:
      return 'one';
    case 2:
      return 'a couple';
    case 3:
      return 'a few';
    default:
      return 'lots';
  }
}
```

The same Cyclomatic Complexity as `sumOfPrimes` by the paper's counting, one
seventh of the Cognitive Complexity, and anyone who has read both functions
agrees with the second number.

Two caveats on the numbers here. Adding or removing cases does not move the
Cognitive Complexity at all: the two-case variant in
[`example/lib/src/cognitive_complexity.dart`](../../example/lib/src/cognitive_complexity.dart)
also scores 1. And this repository currently measures a Cyclomatic Complexity of
**2** for the function above rather than the paper's 4, because of a pre-existing
bug in the cyclomatic visitor described at the end of
[conformance.md](conformance.md). The cognitive number is the one being
demonstrated here, and it is correct.

## Nesting

### Flat branching, cognitive 5

```dart
void flatFunction(int a) {
  if (a == 1) {                     // +1
  } else if (a == 2) {              // +1  (hybrid, never nested)
  } else {                          // +1  (hybrid, never nested)
  }

  for (var i = 0; i < a; i++) {     // +1
  }

  final b = a > 0 && a < 10;        // +1  (one operator run)
}
```

### The same structures nested, cognitive 6

```dart
void nestedFunction(int a) {
  for (var i = 0; i < a; i++) {     // +1  (1 + nesting 0)
    if (i == a) {                   // +2  (1 + nesting 1)
      while (i > 0) {               // +3  (1 + nesting 2)
        i--;
      }
    }
  }
}
```

Three structures either way. Five points flat, six points nested with one fewer
branch, and the gap grows fast with depth. This is the whole point of the metric.

### An `else if` chain with a branch in every arm, cognitive 9

```dart
void elseIfChain(int a) {
  if (a == 1) {          // +1
    if (a == 1) {}       // +2
  } else if (a == 2) {   // +1  hybrid: flat, but still raises nesting
    if (a == 2) {}       // +2
  } else {               // +1  hybrid: flat, but still raises nesting
    if (a == 3) {}       // +2
  }
}
```

The arms cost the same as each other. An `else if` is never charged a nesting
increment for sitting inside the `if` it follows, but its body is nested exactly
as the `then` body is.

## Exceptions, cognitive 8

```dart
void catchClauses(int a) {
  try {
    if (a > 0) {}        // +1  try does not raise nesting
  } on StateError {      // +1
    if (a > 0) {}        // +2
  } catch (e) {          // +1
    if (a > 0) {}        // +2
  } finally {
    if (a > 0) {}        // +1  finally does not raise nesting
  }
}
```

Both clause forms score, `on E` and `catch (e)` alike. The `try` and `finally`
blocks contribute nothing themselves and leave the nesting level alone, which is
why the first and last `if` cost 1 while the two inside the clauses cost 2.

## Closures

```dart
void closureNesting(List<int> numbers) {
  numbers.forEach((number) {   // +0, but nesting is now 1
    if (number > 0) {}         // +2
  });
}                              // total 2

void closureInsideLoop(List<int> numbers) {
  for (final number in numbers) {  // +1
    numbers.forEach((other) {      // +0, but nesting is now 2
      if (other > 0) {}            // +3
    });
  }
}                                  // total 4
```

The lambda is never charged. It only raises the ceiling for what it contains,
which is why callback-heavy code scores higher than it looks like it should.

## Boolean operators

```dart
// cognitive 4
if (a && b && c || d || e && f) { }
//  +1 if, +1 for the || run, +1 for `a && b && c`, +1 for `e && f`

// cognitive 3
if (a && !(b && c)) { }
//  +1 if, +1 for the outer run, +1 for the parenthesised run

// cognitive 1
bool operatorSequenceInReturn(bool a, bool b, bool c) => a && b && c;
//  one run, and it counts even outside a condition
```

Both `if` examples are the paper's, reproduced at its published values. Length
within a run is free; mixing operators, or parenthesising, starts a new run and
costs a point.

## Free of charge

```dart
void unlabeledJumps(List<int> numbers) {
  for (final number in numbers) {   // +1
    if (number < 0) {               // +2
      continue;                     // +0  unlabeled
    }
    if (number > 10) {              // +2
      break;                        // +0  unlabeled
    }
  }

  return;                           // +0
}                                   // total 5
```

Compare with `sumOfPrimes` above, where the `continue outer` costs a point
precisely because the reader has to go and find the label.

## Currently unscored

These are gaps, not rules. They are listed here so the numbers in this document
are not mistaken for correct behaviour. See [conformance.md](conformance.md).

```dart
// scored 0, should be 4 (+1 for, +2 nested if, +1 for the trailing if)
List<int> collectionLiteralControlFlow(List<int> numbers, bool flag) => [
      for (final number in numbers)
        if (number > 0) number,
      if (flag) 0,
    ];

// scored 0, should be 1
String switchExpression(int number) => switch (number) {
      1 => 'one',
      2 => 'a couple',
      _ => 'lots',
    };

// scored 1, should be 2: the guard's `&&` run is never walked
void ifCaseGuard(Object value) {
  if (value case int number when number > 0 && number < 10) {}
}
```
