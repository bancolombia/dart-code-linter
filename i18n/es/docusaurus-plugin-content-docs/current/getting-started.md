---
sidebar_position: 1
title: Getting Started
---
# Guia de inicio con DCL


Dart code Linter - DCL is a tool that helps improve the quality and consistency of Dart code by identifying and reporting problems, such as bugs and code that doesn't follow best practices. It also collects analytical data on the code through calculating code metrics and can be configured to set thresholds for these metrics.

## Installation
Installation
To use DCL, add it as a dev dependency to your project:

```sh
$ dart pub add --dev dart_code_linter
```
_or for a Flutter package_
```sh
$ flutter pub add --dev dart_code_linter
```

## Usage
### CLI

You can run DCL analysis from the console using the following command:

```sh
$ dart pub run dart_code_metrics:metrics analyze lib
```
_or for a Flutter package_
```sh
$ flutter pub run dart_code_metrics:metrics analyze lib
```

DCL also provides other commands such as check-unused-code and check-unused-files that can help you maintain the codebase. For more information on using DCL as a command-line tool, see the Command Line Interface documentation.
### Analyzer plugin

DCL can be used as a plugin for the Dart analyzer, providing instant feedback on found issues directly in your integrated development environment (IDE). For more information on using DCL as an analyzer plugin, see the Analyzer Plugin documentation.
### Library (additional option)

You can use DCL as a library directly in your code. See this example for more information. This might be useful if you have a separate package for linting config and want to run DCL from that package's executable.
## Next Steps

- Learn about the [configuration options](/docs/configuration/) for customizing DCL's behavior.
- Get familiar with the [Command Line Interface](/docs/cli/) for running DCL from the console.
- Test existing [presets](/docs/configuration/presets)
