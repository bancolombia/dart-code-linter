---
sidebar_position: 4
title: CLI
---
import Admonition from '@theme/Admonition';
# Command Line Interface
To use the package as a command-line tool, run:
~~~
$ flutter pub run dart_code_linter:metrics <command> lib
~~~
Alternatively, the package can be installed globally:
~~~
$ flutter pub global activate dart_code_linter
$ metrics <command> lib
~~~

It will produce a result in one of the supported formats:
- Console
- GitHub
- Checkstyle
- Codeclimate
- HTML
- JSON

<Admonition type="info" icon="-" title="INFO">
  <p>
You need to configure rules entry in the analysis_options.yaml to have rules report included into the result.
  </p>
</Admonition>

## Available commands
| Command | Example of use | Short description |
|----------|----------|----------|
| analyze | dart run dart_code_linter:metrics analyze lib   | Reports code metrics, rules and anti-patterns violations. |
| check-unnecessary-nullable   | dart run dart_code_linter:metrics check-unnecessary-nullable lib   | Checks unnecessary nullable parameters.  
check-unused-files    | dart run dart_code_linter:metrics check-unused-files lib   | Checks unused *.dart files.   |
| check-unused-l10n    | dart run dart_code_linter:metrics check-unused-l10n lib   | Checks unused localization in *.dart files.   |
| check-unused-code    | dart run dart_code_linter:metrics check-unused-code lib   | Checks unused code in *.dart files.   |

For additional help on any of the commands:

~~~
$ flutter pub run dart_code_linter:metrics --help <command>
~~~

# Multi-package repositories usage
If you run a command from the root of a multi-package repository (a.k.a. monorepo), it'll pick up analysis_options.yaml files correctly.

Additionally, if you use Melos, you can add custom command to the melos.yaml.
