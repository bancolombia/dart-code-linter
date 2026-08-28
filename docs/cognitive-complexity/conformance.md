# Conformance

How far the `cognitive-complexity` metric matches
[the specification](specification.md) today. Every row was measured against the
implementation, not reasoned about.

## Implemented and verified

| Rule | Verified by |
|------|-------------|
| `if` structural increment plus nesting increment | `scores else and else if as hybrid increments that still raise nesting` |
| `else if` and `else` as flat hybrid increments that still raise nesting | same test, asserts the full `1, 2, 1, 2, 1, 2` breakdown |
| ternary increment plus nesting increment | `scores a ternary operator with a nesting increment` |
| `for`, `for-in`, `while`, `do while` | the `sumOfPrimes` and `unlabeledJumps` tests |
| `switch` and all its cases as a single increment | `scores a switch and all of its cases as a single increment` |
| `catch` per clause, `try` and `finally` ignored and non-nesting | `scores every catch clause, ignoring the try and finally blocks` |
| labeled `break` and `continue` as fundamental increments | `scores the white paper's sumOfPrimes example at 7` |
| plain `break`, `continue` and `return` scoring nothing | `scores nothing for unlabeled break, continue and return` |
| one increment per run of like binary logical operators | `scores each sequence of like binary logical operators once` |
| parenthesised and negated runs counted separately | `scores a negated sequence separately from the one containing it` |
| operator runs outside conditions | `scores a sequence of like operators outside a condition` |
| lambdas raising nesting without being scored | `scores a closure as a nesting level rather than an increment` |
| stacked nesting through a lambda inside a loop | `scores a closure inside a loop as two stacked nesting levels` |

Tests live in
[`cognitive_complexity_flow_visitor_test.dart`](../../test/src/analyzers/lint_analyzer/metrics/metrics_list/cognitive_complexity/cognitive_complexity_flow_visitor_test.dart),
group `CognitiveComplexityFlowVisitor scores`. Each asserts the full
`description: score` breakdown, not just the total, so a compensating pair of
errors cannot pass.

The strongest single check is that the white paper's own `sumOfPrimes` scores
**7**, its published value, with the breakdown `1, 2, 3, 1`.

## Known gaps

Every row except the last is pinned by a test in the group
`CognitiveComplexityFlowVisitor does not yet score`, so the current behaviour
cannot drift unnoticed. **Update those expectations when you close a gap, do not
delete them.** Indirect recursion is the exception: it has no fixture yet, and
one is worth adding.

| Gap | Spec says | Implementation | Cause |
|-----|-----------|----------------|-------|
| Switch expressions | one increment, nesting increment, raises nesting | **0** | no `visitSwitchExpression` override |
| Collection-literal `if` and `for` | scored like their statement forms | **0** | `IfElement` and `ForElement` are never visited |
| `when` guard of an `if-case` | the guard's operator run scores | guard invisible | `visitIfStatement` hand-walks `expression`, `thenStatement` and `elseStatement`, and omits `caseClause` |
| Recursion cycle | `+1` per **method** in the cycle | `+1` per **call site** | counts each matching `MethodInvocation` |
| `this.foo()` recursion | `+1` for the cycle | **0** | the check requires `node.target == null` |
| Indirect recursion (`a` calls `b` calls `a`) | `+1` for each method | **0** (unpinned) | only self-calls by name are considered |

Worked numbers for the recursion rows:

```dart
int fibonacci(int n) {
  if (n < 2) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}
// specification: 2   (if: 1, recursion cycle: 1)
// implementation: 3  (if: 1, call: 1, call: 1)
```

```dart
int factorial(int n) {
  if (n <= 1) return 1;
  return n * this.factorial(n - 1);
}
// specification: 2   (if: 1, recursion cycle: 1)
// implementation: 1  (if: 1)
```

The `caseClause` gap is the one to treat as a bug rather than a missing feature:
it drops a whole subtree from the traversal, so anything inside the clause is
invisible, not merely unscored. A closure or a nested ternary in a guard costs
nothing today.

## Severity, in the order worth fixing

1. **Switch expressions.** Idiomatic modern Dart, silently free. A metric that
   reports zero for a real branch is worse than one that reports nothing at all.
2. **The `caseClause` traversal.** A dropped subtree, small fix, no design
   question.
3. **Recursion semantics.** Needs element resolution rather than name matching to
   do properly, which also buys indirect cycles and `this.` calls in one change.
4. **Collection-literal `if` and `for`.** Real per the spec, but the cyclomatic
   metric has the same blind spot, so the two should probably move together.

## Neighbouring behaviour, not a gap in this metric

The Cyclomatic Complexity visitor overrides `visitSwitchCase`, but under Dart 3
a `case 1:` inside a switch **statement** parses as `SwitchPatternCase`, not the
legacy `SwitchCase`. Only `default:` is counted, so switches are under-counted by
that metric. The paper's `getWords` measures a Cyclomatic Complexity of 2 in this
repository where the paper reports 4. This predates the cognitive metric and is
tracked separately; it is recorded here because anyone comparing the two metrics
on a switch will notice it immediately and assume the new metric is at fault.
