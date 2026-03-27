# Configuration Guide

Dart Code Linter is configured through `analysis_options.yaml` in your project root. All DCL settings go under the `dart_code_linter` key.

## Enabling the Analyzer Plugin

Register DCL as an analyzer plugin so issues appear in your IDE:

```yaml
analyzer:
  plugins:
    - dart_code_linter
```

## Configuration Structure

```yaml
dart_code_linter:
  rules:
    # List of rules to enable
  metrics:
    # Metric thresholds
  metrics-exclude:
    # Glob patterns for files to exclude from metrics
  anti-patterns:
    # Anti-patterns to detect
```

## Rules Configuration

### Enabling Rules

List rules by name under the `rules` key:

```yaml
dart_code_linter:
  rules:
    - avoid-dynamic
    - no-empty-block
    - prefer-trailing-comma
```

### Rules with Parameters

Some rules accept configuration parameters. Use a map instead of a string:

```yaml
dart_code_linter:
  rules:
    - avoid-nested-conditional-expressions:
        acceptable-level: 2
    - prefer-correct-identifier-length:
        min-identifier-length: 3
        max-identifier-length: 30
    - member-ordering:
        order:
          - constructors
          - public-fields
          - private-fields
          - public-methods
          - private-methods
    - no-magic-number:
        allowed: [0, 1, 2, -1]
    - avoid-banned-imports:
        entries:
          - paths: ["some/path"]
            deny: ["package:some_package/some_package.dart"]
            message: "Use the wrapper instead"
    - ban-name:
        entries:
          - ident: "print"
            description: "Use logger instead of print"
    - prefer-correct-type-name:
        min-length: 3
        max-length: 40
    - use-design-system:
        entries:
          - instead: "Text"
            use: "DesignText"
```

## Metrics Configuration

Set threshold values for code metrics. When a metric exceeds its threshold, it is flagged in the analysis output.

```yaml
dart_code_linter:
  metrics:
    cyclomatic-complexity: 20
    number-of-parameters: 4
    maximum-nesting-level: 5
    source-lines-of-code: 50
    lines-of-code: 100
    number-of-methods: 10
    weight-of-class: 0.33
    maintainability-index: 50
    halstead-volume: 150
```

### Technical Debt Configuration

Technical debt has sub-configuration for assigning costs:

```yaml
dart_code_linter:
  metrics:
    technical-debt:
      threshold: 1
      todo-cost: 0.5
      ignore-cost: 0.5
      ignore-for-file-cost: 1
      as-dynamic-cost: 1
      deprecated-annotations-cost: 1
      file-nullsafety-migration-cost: 5
      unit-type: "hours"
```

## Excluding Files from Metrics

Use glob patterns to exclude files from metrics analysis:

```yaml
dart_code_linter:
  metrics-exclude:
    - test/**
    - "**.g.dart"
    - "**.freezed.dart"
```

## Anti-Patterns Configuration

Enable anti-pattern detection. Anti-patterns depend on metric thresholds:

```yaml
dart_code_linter:
  anti-patterns:
    - long-method
    - long-parameter-list
```

- `long-method` uses the `source-lines-of-code` threshold
- `long-parameter-list` uses the `number-of-parameters` threshold

## Full Configuration Example

```yaml
analyzer:
  plugins:
    - dart_code_linter

dart_code_linter:
  metrics:
    cyclomatic-complexity: 20
    number-of-parameters: 4
    maximum-nesting-level: 5
    source-lines-of-code: 50
    lines-of-code: 100
    number-of-methods: 10
    weight-of-class: 0.33
    maintainability-index: 50
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
    - "**.g.dart"
    - "**.freezed.dart"
  anti-patterns:
    - long-method
    - long-parameter-list
  rules:
    - avoid-dynamic
    - avoid-passing-async-when-sync-expected
    - avoid-redundant-async
    - avoid-unnecessary-type-assertions
    - avoid-unnecessary-type-casts
    - avoid-unrelated-type-assertions
    - avoid-unused-parameters
    - avoid-nested-conditional-expressions:
        acceptable-level: 2
    - newline-before-return
    - no-boolean-literal-compare
    - no-empty-block
    - no-equal-then-else
    - no-magic-number:
        allowed: [0, 1, 2, -1]
    - prefer-trailing-comma
    - prefer-conditional-expressions
    - prefer-moving-to-variable
    - prefer-match-file-name
    - member-ordering:
        order:
          - constructors
          - public-fields
          - private-fields
          - public-methods
          - private-methods
```

## Tips

- Start with a small set of rules and add more incrementally
- Use `metrics-exclude` to skip generated files (`*.g.dart`, `*.freezed.dart`)
- Set CI exit thresholds with `--set-exit-on-violation-level` in your CI pipeline
- Rules with auto-fixes (marked with a wrench icon) can be applied via your IDE context menu
