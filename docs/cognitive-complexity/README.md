# Cognitive Complexity

Reference material for the `cognitive-complexity` metric: what the metric is
supposed to compute, how each rule maps onto Dart, and how far the current
implementation conforms.

| Document | Contents |
|----------|----------|
| [specification.md](specification.md) | The scoring rules, restated as a checklist an implementer can work from. |
| [dart-mapping.md](dart-mapping.md) | Each rule mapped to Dart syntax, the analyzer AST node, and the code that handles it. |
| [conformance.md](conformance.md) | What Dart Code Linter implements today, and the gaps that are pinned by tests. |
| [examples.md](examples.md) | Worked examples with the score breakdown each one produces. |

## Source

Cognitive Complexity is defined by SonarSource. The normative source is the
white paper:

> G. Ann Campbell, *Cognitive Complexity: a new way of measuring
> understandability*, version 1.7, 29 August 2023.
> <https://www.sonarsource.com/docs/CognitiveComplexity.pdf>

That paper is copyright SonarSource S.A. and is **not** reproduced here. These
documents restate its rules in our own words for the purpose of implementing and
testing the metric, quote only the short normative enumerations and definitions
needed to pin behaviour, and attribute every quotation. Read the paper itself for
the rationale behind the rules, the discussion of why Cognitive Complexity
departs from Cyclomatic Complexity, and the extended examples. Where these
documents and the paper disagree, the paper wins and this repository has a bug,
either in the code or in the docs.

## Why these documents exist

The white paper is deliberately language-neutral. It says so directly, in the
preamble to its specification appendix:

> This is meant to be a comprehensive listing without being language-exhaustive.
> That is, if a language has an atypical spelling for a keyword, such as `elif`
> for `else if`, its omission here is not intended to omit it from the
> specification.

Dart has several structures the paper never names: collection-literal `if` and
`for`, switch expressions, pattern `if-case` clauses with `when` guards. Deciding
how those score is an act of interpretation, and that interpretation needs to be
written down somewhere other than a pull request comment thread. That is what
[dart-mapping.md](dart-mapping.md) is for, and [conformance.md](conformance.md)
records which of those decisions the code has actually caught up with.

## Keeping this honest

Every score quoted in these documents was measured against the implementation,
not derived by hand. The fixtures live in
[`test/resources/cognitive_complexity_rules_example.dart`](../../test/resources/cognitive_complexity_rules_example.dart)
and
[`test/resources/cognitive_complexity_metric_example.dart`](../../test/resources/cognitive_complexity_metric_example.dart),
and the assertions live in
[`cognitive_complexity_flow_visitor_test.dart`](../../test/src/analyzers/lint_analyzer/metrics/metrics_list/cognitive_complexity/cognitive_complexity_flow_visitor_test.dart).
If you change the visitor, those tests are the thing that tells you which of the
numbers below moved.
