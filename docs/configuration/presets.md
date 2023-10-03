# Presets

DCL includes 3 sets of predefined configurations:

- All: contains all available lint rules for Dart and Flutter.
- Dart: contains all lint rules applicable to any Dart app.
- Flutter: contains all lint rules applicable to any Flutter app.

:::info

While presets are a great way to keep track of rule list updates, upgrading to a newer version of DCL can introduce new issues if the preset has been updated.

Consider this before choosing a preset.
:::
## Enabling a Preset

To enable a preset:

For DCL configuration add the extents entry:

```analysis_options.yaml

dart_code_linter:
  extends:
    - package:dart_code_linter/presets/all.yaml
```

## Reconfiguring a Rule

To reconfigure a rule included into a preset:
```analysis_options.yaml

dart_code_linter:
  extends:
    - package:dart_code_linter/presets/all.yaml
  rules:
    - arguments-ordering:
        child-last: true
```

## Disabling a Rule

To disable a rule set its configuration to : false:
analysis_options.yaml

```dart_code_linter:
  extends:
    - package:dart_code_linter/presets/all.yaml
  rules:
    - avoid-banned-imports: false
```

## Defining a Custom Preset
Any other preset can be passed to the extends entry. To create a custom preset create a yaml file with the same structure as for regular [DCL configuration](../configuration/configuration.md).