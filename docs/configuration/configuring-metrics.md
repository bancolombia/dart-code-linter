# Configuring Metrics

Metrics are one of the core building blocks of DCL. Metrics help you understand the complexity of your code and identify areas that may be difficult to maintain or test.

All metrics are configurable.

## Enabling a Metric

To enable a metric add its id to the metrics entry:

```analysis_options.yaml

dart_code_linter:
  metrics:
    - cyclomatic-complexity: 20
```

## Excluding Files for All Metrics

To exclude files from a metrics report provide a list of regular expressions for ignored files:

```analysis_options.yaml

dart_code_linter:
  metrics-exclude:
    - test/**
    - lib/src/some_file.dart
    ```