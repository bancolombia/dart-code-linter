# CLI Commands Reference

Dart Code Linter provides a CLI tool accessible via `dart run dart_code_linter:metrics`. It supports multiple commands for analyzing code quality, finding unused code, and more.

## General Usage

```sh
dart run dart_code_linter:metrics <command> [arguments]
```

For help on any command:

```sh
dart run dart_code_linter:metrics help <command>
```

## Commands

### analyze

Reports code metrics, rule violations, and anti-pattern issues.

```sh
dart run dart_code_linter:metrics analyze lib
```

**Key flags:**

| Flag | Description |
|------|-------------|
| `--reporter=<value>` | Output format: `console` (default), `github`, `codeclimate`, `html`, `json` |
| `--output-directory=<path>` | Directory for HTML report output |
| `--root-folder=<path>` | Root folder of the project |
| `--exclude=<glob>` | One glob of files to exclude, see [Excluding Files](#excluding-files) |
| `--set-exit-on-violation-level=<level>` | Set exit code when violations reach this level: `noted`, `warning`, `alarm` |
| `--fatal-style` | Treat style violations as fatal |
| `--fatal-performance` | Treat performance violations as fatal |
| `--fatal-warnings` | Treat warnings as fatal |
| `--no-congratulate` | Suppress congratulatory messages |

**Output formats:**

- **Console**: Human-readable output to terminal
- **GitHub**: GitHub Actions compatible annotations
- **Codeclimate**: Code Climate compatible JSON
- **HTML**: Interactive HTML report
- **JSON**: Machine-readable JSON output

**Examples:**

```sh
# Analyze with JSON output
dart run dart_code_linter:metrics analyze --reporter=json lib

# Generate HTML report
dart run dart_code_linter:metrics analyze --reporter=html --output-directory=reports lib

# Fail CI on warnings
dart run dart_code_linter:metrics analyze --set-exit-on-violation-level=warning lib

# GitHub Actions integration
dart run dart_code_linter:metrics analyze --reporter=github lib
```

### check-unused-files

Checks for unused `*.dart` files in the project.

```sh
dart run dart_code_linter:metrics check-unused-files lib
```

**Key flags:**

| Flag | Description |
|------|-------------|
| `--reporter=<value>` | Output format: `console` (default), `json` |
| `--root-folder=<path>` | Root folder of the project |
| `--exclude=<glob>` | One glob of files to exclude, see [Excluding Files](#excluding-files) |
| `--no-congratulate` | Suppress congratulatory messages |

**Example:**

```sh
dart run dart_code_linter:metrics check-unused-files --reporter=json lib
```

### check-unused-code

Checks for unused code (classes, functions, variables, etc.) in `*.dart` files.

```sh
dart run dart_code_linter:metrics check-unused-code lib
```

**Key flags:**

| Flag | Description |
|------|-------------|
| `--reporter=<value>` | Output format: `console` (default), `json` |
| `--root-folder=<path>` | Root folder of the project |
| `--exclude=<glob>` | One glob of files to exclude, see [Excluding Files](#excluding-files) |
| `--no-congratulate` | Suppress congratulatory messages |

**Example:**

```sh
dart run dart_code_linter:metrics check-unused-code --reporter=json lib
```

### check-unused-l10n

Checks for unused localization members in Dart classes that use the `intl` package.

```sh
dart run dart_code_linter:metrics check-unused-l10n lib
```

An example of a localization class:

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

**Key flags:**

| Flag | Description |
|------|-------------|
| `--reporter=<value>` | Output format: `console` (default), `json` |
| `--root-folder=<path>` | Root folder of the project |
| `--exclude=<glob>` | One glob of files to exclude, see [Excluding Files](#excluding-files) |
| `--class-pattern=<regex>` | Regex pattern to match localization class names |
| `--no-congratulate` | Suppress congratulatory messages |

**Example:**

```sh
dart run dart_code_linter:metrics check-unused-l10n --class-pattern=".*I18n" lib
```

### check-unnecessary-nullable

Checks for unnecessary nullable parameters in functions, methods, and constructors.

```sh
dart run dart_code_linter:metrics check-unnecessary-nullable lib
```

**Key flags:**

| Flag | Description |
|------|-------------|
| `--reporter=<value>` | Output format: `console` (default), `json` |
| `--root-folder=<path>` | Root folder of the project |
| `--exclude=<glob>` | One glob of files to exclude, see [Excluding Files](#excluding-files) |
| `--no-congratulate` | Suppress congratulatory messages |

**Example:**

```sh
dart run dart_code_linter:metrics check-unnecessary-nullable --reporter=json lib
```

## Excluding Files

`--exclude` takes a single glob, relative to the root folder. It defaults to `{/**.g.dart,/**.freezed.dart}`, which skips the generated `*.g.dart` and `*.freezed.dart` files.

- To exclude several patterns, put them in one brace group. A comma outside braces is read as part of the file name, so `lib/a.dart,lib/b.dart` excludes nothing, and repeating the flag keeps only the last value.
- Passing `--exclude` replaces the default, so keep the generated files in the group if they should stay excluded:

```sh
dart run dart_code_linter:metrics check-unused-code lib --exclude="{**.g.dart,**.freezed.dart,lib/gen/**}"
```

`check-unused-files`, `check-unused-code`, `check-unused-l10n` and `check-unnecessary-nullable` do not report excluded files, but still count them as users of other code, so code used only from generated files is not reported. Files listed under `analyzer: exclude:` in `analysis_options.yaml` are not analyzed at all.

## Monorepo Support

DCL automatically picks up `analysis_options.yaml` files in multi-package repositories. You can define one `analysis_options.yaml` at the root, and each package will inherit its configuration.

## CI/CD Integration

Use the `--set-exit-on-violation-level` flag to fail builds when violations reach a threshold:

```sh
# Fail on any warning or above
dart run dart_code_linter:metrics analyze --set-exit-on-violation-level=warning lib

# GitHub Actions reporter for inline annotations
dart run dart_code_linter:metrics analyze --reporter=github lib
```
