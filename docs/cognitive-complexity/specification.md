# The scoring rules

Restated from SonarSource's Cognitive Complexity white paper, version 1.7. See
[README.md](README.md) for the source and the terms under which this summary
exists. For the reasoning behind each rule, read the paper.

## The idea in one paragraph

Cyclomatic Complexity counts execution paths, which makes it a good measure of
how many tests a function needs and a poor measure of how hard the function is to
read. Cognitive Complexity drops the path-counting model. It scores a function by
walking its control flow and charging for each break in the reader's linear
top-to-bottom flow, charging more when those breaks are nested inside one
another, and charging nothing for structures that compress many statements into
one readable shorthand. A `switch` with ten cases is one charge, because a reader
takes it in at a glance. Three `if`s nested three deep is six, because the reader
has to hold each enclosing condition in their head.

## The three basic rules

1. Ignore structures that allow multiple statements to be readably shorthanded
   into one.
2. Increment (add one) for each break in the linear flow of the code.
3. Increment when flow-breaking structures are nested.

## The four kinds of increment

| Kind | Scored? | Raises nesting? | Applies to |
|------|---------|-----------------|------------|
| **Structural** | yes, `1 + nesting` | yes | `if`, ternary, loops, `switch`, `catch` |
| **Nesting** | the `+ nesting` part of the above | n/a | the same structures, once nested |
| **Fundamental** | yes, always `+1` | no | labeled jumps, operator sequences, recursion |
| **Hybrid** | yes, always `+1` | yes | `else`, `else if` |

The hybrid kind is the one that catches people out. `else` and `else if` are
charged a flat `+1` no matter how deeply nested they are, because, in the paper's
words, "the mental cost has already been paid when reading the `if`". But they
still raise the nesting level for whatever they contain, so an `if` inside an
`else` block costs the same as an `if` inside the matching `then` block.

## Increments

There is an increment for each of the following:

- `if`, `else if`, `else`, ternary operator
- `switch`
- `for`, `foreach`
- `while`, `do while`
- `catch`
- `goto LABEL`, `break LABEL`, `continue LABEL`, `break NUMBER`, `continue NUMBER`
- sequences of binary logical operators
- each method in a recursion cycle

## Nesting level

The following structures raise the nesting level of everything inside them:

- `if`, `else if`, `else`, ternary operator
- `switch`
- `for`, `foreach`
- `while`, `do while`
- `catch`
- nested methods and method-like structures such as lambdas

## Nesting increments

The following receive a nesting increment proportional to how deep inside
nesting-level structures they sit:

- `if`, ternary operator
- `switch`
- `for`, `foreach`
- `while`, `do while`
- `catch`

Note what is absent from this third list but present in the first two: `else`,
`else if` (hybrid, flat `+1`), and lambdas (raise nesting, are never scored
themselves).

## Rules that need spelling out

### Switches

A `switch` and all of its cases combined incur a single structural increment. The
number of cases is irrelevant. This is the sharpest departure from Cyclomatic
Complexity, which charges per case, and it is deliberate: a `switch` compares one
variable against a set of literals, while an equivalent `if`/`else if` chain may
compare any number of variables using any number of operators.

### Catches

Each `catch` clause is one structural increment, no matter how many exception
types it catches. `try` and `finally` blocks are ignored altogether, and neither
raises the nesting level. So an `if` directly inside a `try` costs 1, while the
same `if` inside the `catch` costs 2.

### Sequences of binary logical operators

Not one increment per operator. One increment per *run of like operators*.
Understanding `a && b && c && d` is barely harder than understanding `a && b`,
but `a || b && c || d` is markedly harder than either, so mixing is what gets
charged. Parentheses break a run. The paper's two examples:

```
if (a          // +1 for `if`
    && b && c  // +1
    || d || e  // +1
    && f)      // +1   -> 4

if (a          // +1 for `if`
    &&         // +1
    !(b && c)) // +1   -> 3
```

This applies everywhere binary boolean operators appear, not just in conditions:
assignments, arguments and return statements are all scored.

### Recursion

One fundamental increment for **each method in a recursion cycle**, direct or
indirect. Not one per call site. A method that calls itself twice is charged
once; two methods that call each other are charged once each. Recursion is a kind
of meta-loop, and Cognitive Complexity charges for loops.

### Jumps to labels

`goto`, and `break`/`continue` to a label or to a level number, are fundamental
increments. Plain `break`, plain `continue` and early `return` are free, "because
an early return can often make code much clearer".

### Nested functions and lambdas

A nested function or lambda is never itself scored, but it raises the nesting
level for its body. A branch inside a callback inside a loop is charged for both
enclosing levels.

## Compensating usages

The paper carves out exactly two language-specific exemptions, neither of which
applies to Dart:

- **JavaScript**: an outer function used purely as a namespace, containing only
  declarations at the top level, is ignored and does not raise nesting.
- **Python**: a decorator, narrowly defined as a function containing only a
  nested function and a `return`, is ignored and does not raise nesting.

There is no exemption for comprehensions, collection literals, or any other
compressed control-flow syntax. That matters for Dart and is worked through in
[dart-mapping.md](dart-mapping.md).

## Reference values

Two functions from the paper, used throughout as calibration. By the paper's
counting both have a Cyclomatic Complexity of 4, which is the point: the metric
that scores them equally is not measuring readability.

| Function | Cognitive | Why |
|----------|-----------|-----|
| `sumOfPrimes`, two nested loops around an `if` with a labeled `continue` | **7** | 1 + 2 + 3 + 1 |
| `getWords`, a `switch` with three cases and a default | **1** | the whole switch is one increment |

Dart Code Linter reproduces both cognitive values. See
[examples.md](examples.md), which also notes why it does not reproduce the
cyclomatic ones.
