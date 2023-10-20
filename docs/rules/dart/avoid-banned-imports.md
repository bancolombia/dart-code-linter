import Admonition from '@theme/Admonition';

# avoid-banned-imports

Configure some imports that you want to ban.

## Config
Set `entries` (default is empty) to configure a list of entries for imports to ban.

Each entry is an object with 3 fields: `paths`, `deny` and `message`.

Set paths (can be a regular expression) to configure the list of paths for entry to trigger on.

Set `deny` (can be a regular expression) to configure the list of imports to ban.

Set `message` to configure a user-facing message for each issue created from this config entry.

```dart
dart_code_metrics:
  ...
  rules:
    ...
    - avoid-banned-imports:
        entries:
        - paths: ['some/folder/.*\.dart', 'another/folder/.*\.dart']
          deny: ['package:flutter/material.dart']
          message: 'Do not import Flutter Material Design library, we should not depend on it!'
        - paths: ['core/.*\.dart']
          deny: ['package:flutter_bloc/flutter_bloc.dart']
          message: 'State management should be not used inside "core" folder.'
```

<Admonition type="info" icon="" title="NOTE">
This rule requires configuration in order to highlight any issues.
</Admonition>

## Example
With the configuration in the example above, here are some bad/good examples.

### Bad:

```dart
import "package:flutter/material.dart"; // LINT
import "package:flutter_bloc/flutter_bloc.dart"; // LINT
```

### Good:

```dart:
// No restricted imports in listed folders.
```
