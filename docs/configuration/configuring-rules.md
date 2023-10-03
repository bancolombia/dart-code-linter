# Configuring Rules

Rules are one of the core building blocks of DCM. A rule validates if your code meets a certain expectation, and what to do if it does not meet that expectation.

All rules can be configured with severity, exclude and include options, but some rules also have additional configuration options specific to that rule and are marked with ⚙️.
## Enabling a Rule

To enable a rule add its id to the rules entry:
```analysis_options.yaml

dart_code_linter:
  rules:
    - newline-before-return
```
## Rule Severities

To change a rule's severity, configure the rule with one of these values:

- none
- style
- performance
- warning
- error

```analysis_options.yaml

dart_code_linter:
  rules:
    - newline-before-return:
        severity: style
```
## Excluding Files

To exclude specific files from rule's analysis, configure the rule exclude option:
```analysis_options.yaml

dart_code_linter:
  rules:
    - newline-before-return:
        exclude:
          - test/**
```
## Excluding Files for All Rules

To exclude a file for all the rules, configure global rules-exclude option:
```analysis_options.yaml

dart_code_linter:
  rules-exclude:
    - test/**
    - lib/src/some_file.dart
```
## Including Files

To include specific files to rule's analysis, configure the rule include option:
```analysis_options.yaml

```dart_code_linter:
  rules:
    - newline-before-return:
        include:
          - test/**
```
:::info

All files are included by default.
:::

## Disabling a Rule

If you include an analysis options file (which has DCM configuration) or use a preset, you might want to disable some of the included rules. Disabling individual rules is similar to enabling them, but the name of a rule should be followed by either : false or : true.

Here's an example of an analysis options file that has a disabled rule:
```analysis_options.yaml

include: package:my_lints/all.yaml

dart_code_linter:
  rules:
    - newline-before-return: false
    ```