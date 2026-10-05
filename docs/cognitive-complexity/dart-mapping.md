# Mapping the rules onto Dart

The white paper is language-neutral by design, and says so: its enumeration is
"a comprehensive listing without being language-exhaustive", and a language's
atypical spelling of a construct is still that construct. This document decides
what that means for Dart, and points at the code.

All implementation references are to
[`cognitive_complexity_flow_visitor.dart`](../../lib/src/analyzers/lint_analyzer/metrics/metrics_list/cognitive_complexity/cognitive_complexity_flow_visitor.dart).

## Direct translations

These have an unambiguous Dart spelling and an unambiguous AST node.

| Rule | Dart | AST node | Handled in |
|------|------|----------|-----------|
| `if` | `if (c) { }` | `IfStatement` | `visitIfStatement`, line 52 |
| `else if` | `} else if (c) {` | `IfStatement` whose parent's `elseStatement` is it | `visitIfStatement`, line 52 |
| `else` | `} else {` | `IfStatement.elseKeyword` | `visitIfStatement`, line 52 |
| ternary | `c ? a : b` | `ConditionalExpression` | `visitConditionalExpression`, line 78 |
| `for`, `foreach` | `for (;;)`, `for (x in xs)` | `ForStatement` (both forms) | `visitForStatement`, line 87 |
| `while` | `while (c) { }` | `WhileStatement` | `visitWhileStatement`, line 95 |
| `do while` | `do { } while (c);` | `DoStatement` | `visitDoStatement`, line 103 |
| `switch` | `switch (x) { case ...: }` | `SwitchStatement` | `visitSwitchStatement`, line 111 |
| `catch` | `catch (e)` and `on E` | `CatchClause` | `visitCatchClause`, line 123 |
| labeled jump | `break label;`, `continue label;` | `BreakStatement`/`ContinueStatement` with a non-null `label` | lines 146 and 155 |
| operator sequence | `&&`, `\|\|` runs | `BinaryExpression` | `visitBinaryExpression`, line 164 |
| nested method / lambda | `(x) { }`, `() => x`, local functions | `FunctionExpression` | `visitFunctionExpression`, line 133 |
| recursion | a self-call | `MethodInvocation` | `visitMethodInvocation`, line 181 |

Two Dart details worth noting in that table:

- **`for-in` is `foreach`.** Dart uses one node, `ForStatement`, for both the
  C-style and the iterating form, distinguished by its `forLoopParts`. The paper
  charges both identically, so one visit method covers both.
- **`on E` without `catch`.** Dart lets you write `on StateError { }` with no
  catch clause parameter. It is still a `CatchClause`, still one increment, and
  the visitor falls back from `catchKeyword` to `onKeyword` to locate the
  reported token.

## Dart structures the paper never names

These are the interpretation calls. Each is a construct the paper's enumeration
covers in substance but not by name.

### Collection-literal `if` and `for`

```dart
final visible = [
  for (final item in items)
    if (item.isVisible) item,
];
```

These are the `for` and `if` of Appendix B, written in a position where Dart
allows an element instead of a statement. The AST calls them `ForElement` and
`IfElement` rather than `ForStatement` and `IfStatement`, but nothing about the
reader's experience differs: the flow breaks, and the `if` is nested inside the
`for`.

**They should score**, exactly as their statement forms do: `+1` for the `for`,
`+2` for the nested `if`. The paper's only exemptions are for JavaScript
namespace functions and Python decorators; there is no comprehension exemption to
appeal to. The rule about ignoring "structures that allow multiple statements to
be readably shorthanded into one" is about things like `switch`, which collapses
a chain of comparisons into one glanceable construct, not about relocating a loop
into a literal.

Not implemented today. See [conformance.md](conformance.md).

### Switch expressions

```dart
final name = switch (number) {
  1 => 'one',
  2 => 'a couple',
  _ => 'lots',
};
```

A `switch` is a `switch`. Dart 3's expression form is a `SwitchExpression` node
rather than a `SwitchStatement`, but the rule is unchanged: **one increment for
the whole thing regardless of case count**, a nesting increment when nested, and
it raises the nesting level for its case bodies. Guards (`when`) inside it
contain expressions that score under the ordinary rules.

Not implemented today. See [conformance.md](conformance.md).

### Pattern `if-case` and `when` guards

```dart
if (value case int number when number > 0 && number < 10) { }
```

The `if` scores as any `if` does. The guard is an ordinary boolean expression, so
its `&&` run scores `+1` as a sequence of binary logical operators, the same as
it would in a plain condition. A guard is not itself a separate flow break: it is
part of the one `if`.

The `when` guard of a `switch` **statement** already scores correctly, because
that traversal path goes through the base visitor. The guard of an `if-case` does
not, because `visitIfStatement` walks its children by hand and does not include
the case clause. See [conformance.md](conformance.md).

### Recursion in a Dart-shaped world

The paper charges once per method in a recursion cycle. Detecting that properly
means resolving each call to an element and looking for cycles among the
functions in the unit. A name-based check on unqualified calls approximates it
but diverges in three ways: it charges per call site rather than per method, it
misses `this.foo()`, and it misses indirect cycles. See
[conformance.md](conformance.md).

### Things that correctly score nothing

Worth recording so nobody "fixes" them:

- `??`, `?.`, `??=`. Cyclomatic Complexity charges for these in this codebase.
  Cognitive Complexity is "only concerned with binary boolean operators", and
  null-aware operators are not flow breaks a reader has to unpack. Zero.
- `await`, `yield`, `async*`. Not branches.
- `assert`. Not a branch in the reader's flow.
- Plain `break`, plain `continue`, `return`, including early returns. Explicitly
  free per the paper: an early return usually makes code clearer.
- `try` and `finally` blocks. Ignored, and they do not raise nesting. Only
  `catch` scores.
- Cascades, spreads, `for` inside a string interpolation. Not control flow.

## Which node a score is reported on

The metric reports each increment as a `ContextMessage` anchored at a specific
token, so the HTML and console reporters can point at the line that cost the
points. The visitor deliberately anchors to the keyword rather than the whole
node: `ifKeyword`, `forKeyword`, `whileKeyword`, `switchKeyword`, the `?` of a
ternary, the operator token of a logical run. A whole-node anchor would span the
entire body and make the report useless.
