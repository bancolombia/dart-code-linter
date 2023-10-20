# avoid-double-slash-imports
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when an import/export directive contains a double slash.

Double slash in the URI is considered valid, but under some circumstances the program won't run.

See:

- https://github.com/dart-lang/sdk/issues/36337
## Example
### Bad:
```dart
import 'package:test//material.dart'; // LINT
import 'package:mocktail/good_file.dart';
import '../../..//rule_utils_test.dart'; // LINT

export 'package:mocktail//good_file.dart'; // LINT

part '../../..//individual/rules/empty.dart'; // LINT
```
### Good:
```dart
import 'package:test/material.dart';
import 'package:mocktail/good_file.dart';
import '../../../rule_utils_test.dart';

export 'package:mocktail/good_file.dart';

part '../../../individual/rules/empty.dart';
```
