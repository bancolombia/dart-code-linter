# Code Metrics Reference

Dart Code Linter provides 11 code metrics to measure code complexity, maintainability, and technical debt. Metrics are configured in `analysis_options.yaml` under `dart_code_linter > metrics`.

## Function-Level Metrics

These metrics are computed per function or method.

### Cyclomatic Complexity (CYCLO)

Measures the number of linearly independent paths through a function's source code. Higher values indicate more complex, harder-to-test code.

- **Config key:** `cyclomatic-complexity`
- **Default threshold:** 20
- **Measured on:** Functions and methods

### Cognitive Complexity (COGNITIVE)

Measures how difficult a function is for a human to read and understand, based on SonarSource's Cognitive Complexity algorithm. Unlike cyclomatic complexity, control flow nested inside other control flow is penalized more heavily than the same control flow written flat.

- **Config key:** `cognitive-complexity`
- **Default threshold:** 20
- **Measured on:** Functions and methods

### Lines of Code (LOC)

Counts the total number of lines a function occupies, including comments and blank lines.

- **Config key:** `lines-of-code`
- **Default threshold:** 100
- **Measured on:** Functions and methods

### Source Lines of Code (SLOC)

Counts only the lines containing actual source code, excluding comments and blank lines. Used to estimate development effort and maintainability.

- **Config key:** `source-lines-of-code`
- **Default threshold:** 50
- **Measured on:** Functions and methods

### Number of Parameters (NOP)

Counts the number of parameters received by a function or method. Methods named `copyWith` that return the enclosing class type are excluded.

- **Config key:** `number-of-parameters`
- **Default threshold:** 4
- **Measured on:** Functions and methods

### Maximum Nesting Level (MAXNESTING)

Measures the deepest level of nested control structures (if/else, for, while, switch, try/catch) in a function. Deep nesting makes code harder to read and maintain.

- **Config key:** `maximum-nesting-level`
- **Default threshold:** 5
- **Measured on:** Functions and methods

### Halstead Volume (HALVOL)

Measures the "bulk" of code based on the total and unique count of operators and operands. Higher volume means more information a reader must absorb to understand the code.

- **Config key:** `halstead-volume`
- **Default threshold:** 150
- **Measured on:** Functions and methods

### Maintainability Index (MI)

A composite metric that measures how easy code is to maintain. Computed from Cyclomatic Complexity, Halstead Volume, and Source Lines of Code. Values range from 0 to 100; higher is better.

- **Config key:** `maintainability-index`
- **Default threshold:** 50 (minimum; values below this are flagged)
- **Measured on:** Functions and methods
- **Note:** This is an inverted metric -- lower values are worse.

## Class-Level Metrics

These metrics are computed per class.

### Number of Methods (NOM)

Counts the total number of methods in a class.

- **Config key:** `number-of-methods`
- **Default threshold:** 10
- **Measured on:** Classes

### Weight of Class (WOC)

Ratio of functional public methods to total public methods. Functional methods exclude constructors, getters, and setters. Lower values suggest the class may be a data holder rather than providing behavior.

- **Config key:** `weight-of-class`
- **Default threshold:** 0.33 (minimum; values below this are flagged)
- **Measured on:** Classes
- **Note:** This is an inverted metric -- lower values are worse.

## File-Level Metrics

### Technical Debt (TECHDEBT)

Estimates the cost of technical debt in a file by assigning configurable cost values to TODO comments, analyzer ignore directives, `as dynamic` expressions, deprecated annotations, and non-null-safety code.

- **Config key:** `technical-debt`
- **Default threshold:** 0
- **Measured on:** Files
- **Sub-configuration:**
  - `todo-cost`: Cost per TODO comment (default: 0)
  - `ignore-cost`: Cost per `// ignore:` comment (default: 0)
  - `ignore-for-file-cost`: Cost per `// ignore_for_file:` comment (default: 0)
  - `as-dynamic-cost`: Cost per `as dynamic` expression (default: 0)
  - `deprecated-annotations-cost`: Cost per `@deprecated` annotation (default: 0)
  - `file-nullsafety-migration-cost`: Cost per non-null-safety language comment (default: 0)
  - `unit-type`: Label for the unit of measurement (e.g., "hours")

## Anti-Patterns

DCL also detects two anti-patterns that depend on metrics:

### Long Method

Flags methods that exceed the configured source lines of code threshold.

- **Config key:** `long-method`
- **Depends on:** `source-lines-of-code` metric threshold

### Long Parameter List

Flags methods that exceed the configured number of parameters threshold.

- **Config key:** `long-parameter-list`
- **Depends on:** `number-of-parameters` metric threshold

## Configuration Example

```yaml
dart_code_linter:
  metrics:
    cyclomatic-complexity: 20
    cognitive-complexity: 20
    number-of-parameters: 4
    maximum-nesting-level: 5
    source-lines-of-code: 50
    lines-of-code: 100
    number-of-methods: 10
    weight-of-class: 0.33
    maintainability-index: 50
    halstead-volume: 150
    technical-debt:
      threshold: 1
      todo-cost: 0.5
      ignore-cost: 0.5
      ignore-for-file-cost: 1
      as-dynamic-cost: 1
      deprecated-annotations-cost: 1
      file-nullsafety-migration-cost: 5
      unit-type: "hours"
  metrics-exclude:
    - test/**
  anti-patterns:
    - long-method
    - long-parameter-list
```
