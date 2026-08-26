## Dart Code Linter
[![Pub](https://img.shields.io/pub/v/dart_code_linter.svg)](https://pub.dev/packages/dart_code_linter)

Dart Code Linter (DCL) is a powerful toolkit designed to enhance your development process by identifying and resolving issues within your Dart and Flutter code. Whether you're dealing with potential runtime bugs, violations of best practices, or styling concerns, DCL has got you covered. With a comprehensive collection of over 70 pre-built rules, you can effortlessly validate your code against a variety of expectations. Furthermore, DCL offers the flexibility to customize these rules to cater to your specific requirements, ensuring an optimized coding experience.


## Links

- See [CHANGELOG.md](./CHANGELOG.md) for major/breaking updates, and [releases](https://github.com/bancolombia/dart-code-linter/releases) for a detailed version history.
- To contribute, please read [CONTRIBUTING.md](./CONTRIBUTING.md) first.
- Please [open an issue](https://github.com/bancolombia/dart-code-linter/issues/new/choose) if anything is missing or unclear in this documentation.

## Installation

```sh
dart pub add --dev dart_code_linter
```

## Basic configuration

Add configuration to `analysis_options.yaml` and reload IDE to allow the analyzer to discover the plugin config.


### Basic config example

```yaml title="analysis_options.yaml"
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

### Basic config with metrics

```yaml title="analysis_options.yaml"
analyzer:
  plugins:
    - dart_code_linter

dart_code_linter:
  metrics:
    cyclomatic-complexity: 20
    number-of-parameters: 4
    maximum-nesting-level: 5
  metrics-exclude:
    - test/**
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

## Usage

### Analyzer plugin

DCL can be used as a plugin for the Dart `analyzer` [package](https://pub.dev/packages/analyzer) providing additional rules. All issues produced by rules or anti-patterns will be highlighted in the IDE.

Depending on your Dart SDK version, you can configure the plugin in two ways:

#### 1. Analysis Server Plugin (Recommended for Dart >= 3.10)

Dart 3.9 is not supported by this release's plugin integrations. Use Dart >= 3.10 for the Analysis Server Plugin and Dart < 3.9 for the Legacy Analyzer Plugin.
DCL supports the new Dart Analysis Server plugin protocol (`analysis_server_plugin`). To use it, add plugin configuration under the top-level `plugins` key in `analysis_options.yaml`:

```yaml title="analysis_options.yaml"
plugins:
  dart_code_linter:
    diagnostics:
      avoid-dynamic: true
      no-magic-number: warning

dart_code_linter:
  rules:
    - avoid-dynamic
    - no-magic-number:
        severity: warning
        allowed: [42]
```

Top-level `plugins.dart_code_linter.diagnostics` controls IDE enablement and severity. The top-level `dart_code_linter.rules` section supplies full DCL rule configuration, including arbitrary parameters used by both IDE integration and CLI.

Dart 3.13 accepts only scalar diagnostic values in `plugins.dart_code_linter.diagnostics`:

- `true`: enable the rule with its analyzer default severity.
- `false`: disable the rule in the IDE.
- `info`, `warning`, or `error`: enable the rule with that IDE severity.

Do not put a map below `plugins.dart_code_linter.diagnostics.<rule>` on Flutter 3.47 / Dart 3.13. The analyzer rejects that shape with `invalid_section_format` before the plugin runs. Put rule maps under `dart_code_linter.rules` instead.

Rules with mandatory configuration, such as `avoid-banned-imports` and `ban-name`, work with the modern plugin when their configuration lives under `dart_code_linter.rules`.

#### 2. Legacy Analyzer Plugin (Dart < 3.9)

Configure the plugin under `analyzer` in your `analysis_options.yaml`:

```yaml title="analysis_options.yaml"
analyzer:
  plugins:
    - dart_code_linter

dart_code_linter:
  rules:
    - avoid-dynamic
    - prefer-trailing-comma
```

Rules that are marked with 🛠 have auto-fixes available through the IDE context menu. VS Code example:

![VS Code example](https://github.com/bancolombia/dart-code-linter/blob/trunk/assets/quick-fixes.png)

## Compatibility

As DCL depends on the Dart `analyzer` package. The following table shows the compatible versions:

| DCL Version       | Analyzer Version   | Dart SDK          |
|-------------------|--------------------|-------------------|
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



### CLI

The package can be used as CLI and supports multiple commands:

| Command            | Example of use                                            | Short description                                         |
| ------------------ | --------------------------------------------------------- | --------------------------------------------------------- |
| analyze            | dart run dart_code_linter:metrics analyze lib            | Reports code metrics, rules and anti-patterns violations. |
| check-unnecessary-nullable | dart run dart_code_linter:metrics check-unnecessary-nullable lib | Checks unnecessary nullable parameters in functions, methods, constructors. |
| check-unused-files | dart run dart_code_linter:metrics check-unused-files lib | Checks unused \*.dart files.                              |
| check-unused-l10n  | dart run dart_code_linter:metrics check-unused-l10n lib  | Check unused localization in \*.dart files.               |
| check-unused-code  | dart run dart_code_linter:metrics check-unused-code lib  | Checks unused code in \*.dart files.                      |

For additional help on any of the commands, enter `dart run dart_code_linter:metrics help <command>`

**Note:** if you're setting up DCL for multi-package repository (a.k.a. monorepo), it'll pick up analysis_options.yaml files correctly.

You can define one analysis_options.yaml at the root file.

#### Analyze

Reports code metrics, rules and anti-patterns violations. To execute the command, run

```sh
dart run dart_code_linter:metrics analyze lib
```

It will produce a result in one of the format:

- Console
- GitHub
- Codeclimate
- HTML
- JSON



#### Check unnecessary nullable parameters

Checks unnecessary nullable parameters in functions, methods, constructors. To execute the command, run

```sh
dart run dart_code_linter:metrics check-unnecessary-nullable lib
```

It will produce a result in one of the format:

- Console
- JSON



#### Check unused files

Checks unused `*.dart` files. To execute the command, run

```sh
dart run dart_code_linter:metrics check-unused-files lib
```

It will produce a result in one of the format:

- Console
- JSON


#### Check unused localization

Checks unused Dart class members, that encapsulates the app’s localized values.

An example of such class:

```dart
class ClassWithLocalization {
  String get title {
    return Intl.message(
      'Hello World',
      name: 'title',
      desc: 'Title for the Demo application',
      locale: localeName,
    );
  }
}
```

To execute the command, run

```sh
dart run dart_code_linter:metrics check-unused-l10n lib
```

It will produce a result in one of the format:

- Console
- JSON


#### Check unused code

Checks unused code in `*.dart` files. To execute the command, run

```sh
dart run dart_code_linter:metrics check-unused-code lib
```

It will produce a result in one of the format:

- Console
- JSON

By default only top level declarations (classes, functions, variables, and so
on) are checked. Unused private members of type declarations (methods, fields,
getters, setters and named constructors) are reported too when the check is
opted in:

```sh
dart run dart_code_linter:metrics check-unused-code lib --analyze-private-members
```

The same can be enabled through `analysis_options.yaml`, so it applies to every
run:

```yaml
dart_code_linter:
  unused-code:
    analyze-private-members: true
```

The CLI flag wins over the `analysis_options.yaml` value when both are set. Two
limitations are worth knowing about:

- A private field that is only ever assigned, never read, is reported as unused,
  the same way an unused top level variable is.
- Usages that live only in files excluded from analysis (generated `part` files,
  for example) are invisible, so members used exclusively from there are
  reported.

Public members are covered by a separate opt in, because they need more
guesswork than private ones and are therefore less reliable:

```sh
dart run dart_code_linter:metrics check-unused-code lib --analyze-public-members
```

```yaml
dart_code_linter:
  unused-code:
    analyze-public-members: true
```

The two options are independent, so a large project can keep the cheap private
members check on while leaving this one off. Members that cannot be seen to be
used through a reference are skipped rather than reported:

- Members that override or implement an inherited member, since dispatch
  resolves to the supertype's declaration. This covers `toString`, `hashCode`
  and `noSuchMethod` on every class, and overrides that carry no `@override`
  annotation.
- Members annotated `@override`, `@mustBeOverridden`, `@visibleForOverriding`,
  `@redeclare`, `@protected`, `@visibleForTesting`, `@JS`, or
  `@pragma('vm:entry-point')`.
- Members exported to JavaScript with `@JSExport`, which JavaScript calls
  through `createJSInteropWrapper`. This one also counts when the annotation
  sits on the enclosing class, though only for that class's *instance* members,
  since statics are never wrapped. Note that a `@pragma('vm:entry-point')` on
  the enclosing class does *not* work the same way: it only permits allocation
  from native code, so members still need their own pragma and are otherwise
  reported.
- Members whose name is invoked or read somewhere on a target of an unknown
  (`dynamic`) type. Operators count too: a `host + 1`, `host[0] = 1` or
  `host(1)` on a `dynamic` target keeps every `operator +`, `operator []=` and
  `call` member, since any of them could be the one reached.
- `toJson`, which `json.encode` calls by convention rather than by reference.
- Enum constants of an enum whose `values` is referenced anywhere, since
  iteration, `byName` and name based deserialization reach the constants without
  naming any of them.
- Unnamed constructors, whose invocations carry no identifier to record. Named
  constructors are analyzed.

Even so, expect more false positives than from the private members check.
Members reached only through code generation, reflection or a package that
depends on yours cannot be seen at all. Note also that members used only by
your tests are reported when the analysis covers `lib` alone; pass the test
folder too (`check-unused-code lib test`) if you want those usages counted.



## Troubleshooting

Please read [the following guide](./TROUBLESHOOTING.md) if the plugin is not working as you'd expect it to work.

## Contributing

If you are interested in contributing, please check out the [contribution guidelines](./CONTRIBUTING.md). Feedback and contributions are welcome!

## License
Dart Code Linter is licensed under the [MIT](./LICENSE)
