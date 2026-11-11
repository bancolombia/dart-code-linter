# Getting Started with Dart Code Linter

Dart Code Linter (DCL) is a toolkit for identifying and resolving issues in Dart and Flutter code. It provides 70+ lint rules, code metrics, and anti-pattern detection.

## Installation

Add DCL as a dev dependency:

```sh
dart pub add --dev dart_code_linter
```

Or add it manually to your `pubspec.yaml`:

```yaml
dev_dependencies:
  dart_code_linter: ^4.0.0
```

Then run `dart pub get`.

## Basic Setup

Add configuration to `analysis_options.yaml` at your project root:

```yaml
analyzer:
  plugins:
    - dart_code_linter

dart_code_linter:
  rules:
    - avoid-dynamic
    - avoid-passing-async-when-sync-expected
    - avoid-redundant-async
    - avoid-unnecessary-type-assertions
    - avoid-unnecessary-type-casts
    - avoid-unrelated-type-assertions
    - avoid-unused-parameters
    - avoid-nested-conditional-expressions
    - newline-before-return
    - no-boolean-literal-compare
    - no-empty-block
    - prefer-trailing-comma
    - prefer-conditional-expressions
    - no-equal-then-else
    - prefer-moving-to-variable
    - prefer-match-file-name
```

Reload your IDE after adding the configuration so the analyzer plugin discovers it.

## Running Your First Analysis

Run the CLI analyzer on your `lib` directory:

```sh
dart run dart_code_linter:metrics analyze lib
```

This reports code metrics, rule violations, and anti-pattern issues in the console.

## Adding Metrics

To enable code metrics with thresholds:

```yaml
dart_code_linter:
  metrics:
    cyclomatic-complexity: 20
    number-of-parameters: 4
    maximum-nesting-level: 5
  metrics-exclude:
    - test/**
  rules:
    - avoid-dynamic
    # ... more rules
```

## IDE Integration

DCL works as a plugin for the Dart `analyzer` package. All issues produced by rules or anti-patterns are highlighted directly in your IDE. Rules marked with a wrench icon have auto-fixes available through the IDE context menu.

## Compatibility

The Dart SDK column is the range DCL itself declares. The effective floor is higher: every `analyzer` release DCL supports requires Dart `^3.9.0`, so Dart 3.9 is the real minimum regardless of the declared range.

| DCL Version       | Analyzer Version   | Dart SDK          |
|-------------------|--------------------|-------------------|
| 4.4.0             | >=8.2.0 <15.0.0    | >=3.5.0 <4.0.0   |
| 4.3.0             | >=10.0.0 <15.0.0   | >=3.5.0 <4.0.0   |
| 4.2.2             | >=10.0.0 <15.0.0   | >=3.5.0 <4.0.0   |
| 4.2.1             | >=10.0.0 <15.0.0   | >=3.5.0 <4.0.0   |
| 4.2.0             | >=10.0.0 <15.0.0   | >=3.5.0 <4.0.0   |
| 4.1.9             | >=10.0.0 <15.0.0   | >=3.5.0 <4.0.0   |
| 4.1.8             | >=10.0.0 <15.0.0   | >=3.5.0 <4.0.0   |
| 4.1.7             | >=10.0.0 <14.0.0   | >=3.5.0 <4.0.0   |
| 4.1.6             | >=10.0.0 <14.0.0   | >=3.5.0 <4.0.0   |
| 4.1.5             | >=10.0.0 <14.0.0   | >=3.5.0 <4.0.0   |
| 4.1.4             | >=10.0.0 <14.0.0   | >=3.5.0 <4.0.0   |
| 4.1.3             | >=10.0.0 <14.0.0   | >=3.5.0 <4.0.0   |
| 4.1.2             | >=10.0.0 <14.0.0   | >=3.5.0 <4.0.0   |
| 4.1.1             | >=10.0.0 <14.0.0   | >=3.5.0 <4.0.0   |
| 4.1.0             | >=10.0.0 <14.0.0   | >=3.5.0 <4.0.0   |
| 4.0.5             | >=10.0.0 <13.0.0   | >=3.5.0 <4.0.0   |
| 4.0.4             | >=10.0.0 <13.0.0   | >=3.5.0 <4.0.0   |
| 4.0.3             | >=10.0.0 <13.0.0   | >=3.5.0 <4.0.0   |
| 4.0.2             | >=10.0.0 <13.0.0   | >=3.5.0 <4.0.0   |
| 4.0.1             | >=10.0.0 <13.0.0   | >=3.5.0 <4.0.0   |
| 4.0.0             | >=11.0.0 <12.0.0   | >=3.5.0 <4.0.0   |
| >=3.2.0 <4.0.0    | ^8.0.0             | >=3.4.0 <4.0.0   |
| >=3.0.0 <3.2.0    | ^7.4.1             | >=3.4.0 <4.0.0   |
| >=2.0.0 <3.0.0    | ^6.0.0             | >=3.0.0 <4.0.0   |

## Next Steps

- See the **Rules Reference** for a complete list of available lint rules.
- See the **Metrics Reference** for details on code metrics and thresholds.
- See the **CLI Commands Reference** for all available CLI commands.
- See the **Configuration Guide** for advanced configuration options.
