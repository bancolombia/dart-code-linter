## Dart Code Linter

Dart Code Linter (DCL) is a powerful toolkit designed to enhance your development process by identifying and resolving issues within your Dart and Flutter code. Whether you're dealing with potential runtime bugs, violations of best practices, or styling concerns, DCL has got you covered. With a comprehensive collection of over 70 pre-built rules, you can effortlessly validate your code against a variety of expectations. Furthermore, DCL offers the flexibility to customize these rules to cater to your specific requirements, ensuring an optimized coding experience.


## Links

- See [CHANG ELOG.md](./CHANGELOG.md) for major/breaking updates, and [releases](https://github.com/bancolombia/dart-code-linter/releases) for a detailed version history.
- To contribute, please read [CONTRIBUTING.md](./CONTRIBUTING.md) first.
- Please [open an issue](https://github.com/bancolombia/dart-code-linter/issues/new/choose) if anything is missing or unclear in this documentation.

## Installation

```sh
$ dart pub add --dev dart_code_linter

# or for a Flutter package
$ flutter pub add --dev dart_code_linter
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

DCL can be used as a plugin for the Dart `analyzer` [package](https://pub.dev/packages/analyzer) providing additional rules. All issues produced by rules or anti-patterns will be highlighted in IDE.

Rules that marked with 🛠 have auto-fixes available through the IDE context menu. VS Code example:

![VS Code example](https://github.com/bancolombia/dart-code-linter/assets/12372370/8834e8c9-17dd-4d47-b635-24c2d8c1c919)


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
$ dart run dart_code_linter:metrics analyze lib

# or for a Flutter package
$ flutter pub run dart_code_linter:metrics analyze lib
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
$ dart run dart_code_linter:metrics check-unnecessary-nullable lib

# or for a Flutter package
$ flutter pub run dart_code_linter:metrics check-unnecessary-nullable lib
```

It will produce a result in one of the format:

- Console
- JSON



#### Check unused files

Checks unused `*.dart` files. To execute the command, run

```sh
$ dart run dart_code_linter:metrics check-unused-files lib

# or for a Flutter package
$ flutter pub run dart_code_linter:metrics check-unused-files lib
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
$ dart run dart_code_linter:metrics check-unused-l10n lib

# or for a Flutter package
$ flutter pub run dart_code_linter:metrics check-unused-l10n lib
```

It will produce a result in one of the format:

- Console
- JSON


#### Check unused code

Checks unused code in `*.dart` files. To execute the command, run

```sh
$ dart run dart_code_linter:metrics check-unused-code lib

# or for a Flutter package
$ flutter pub run dart_code_linter:metrics check-unused-code lib
```

It will produce a result in one of the format:

- Console
- JSON



## Troubleshooting

Please read [the following guide](./TROUBLESHOOTING.md) if the plugin is not working as you'd expect it to work.

## Contributing

If you are interested in contributing, please check out the [contribution guidelines](./CONTRIBUTING.md). Feedback and contributions are welcome!

## License
Dart Code Linter is licensed under the [MIT](./LICENSE)
