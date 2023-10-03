# Excluding Code from Analysis

:::info

DCL also excludes files listed in the analyzer exclude: option. For example,
```analysis_options.yaml

analyzer:
  exclude:
    - 'example/**'
    - 'build/**'
    - '**/*.g.dart'
    - '**/*.freezed.dart'
```
will also disable DCL analysis for the listed files.
:::

## Using Comments

To ignore a specific rule or anti-pattern warning, add // ignore comment:
```
// ignore: no-empty-block
void emptyFunction() {}
```
End-of-line comments are supported as well. The following communicates the same:
```
void emptyFunction() {} // ignore: no-empty-block
```
To ignore a rule for an entire file, use the ignore_for_file comment. For example,
```
// ignore_for_file: no-empty-block
...
void emptyFunction() {}
```

It's the same approach that the dart linter package use.
:::caution

Analyzer // ignore_for_file: type=lint is currently not supported.
:::
Commands also support ignore via comments. For example, ignore_for_file: unused-code comment will suppress unused code check for an entire file.
## Using Configuration

If you want a specific rule to ignore files, you can configure exclude entry for it. For example,
```analysis_options.yaml

dart_code_linter:
  rules:
    - no-equal-arguments:
        exclude:
          - test/**
```
and similar example for anti-pattern,
```analysis_options.yaml

dart_code_linter:
  anti-patterns:
    - long-method:
        exclude:
          - test/**
```