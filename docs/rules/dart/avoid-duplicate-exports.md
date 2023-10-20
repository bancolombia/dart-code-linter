# avoid-duplicate-exports
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when a file has multiple exports declarations with the same URI.

## Example
### Bad:
```dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

export 'package:my_app/good_folder/something.dart';
export 'package:my_app/good_folder/something.dart'; // LINT
```
### Good:
```dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

export 'package:my_app/good_folder/something.dart';
```
