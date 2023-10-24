# prefer-commenting-analyzer-ignores
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when `// ignore:` comments are left without any additional description why this ignore is applied.

:::info
This rule doesn't trigger on global ignore_for_file: comments.
:::

## Example
### Bad:
```dart
// ignore: deprecated_member_use
final map = Map(); // LINT

// ignore: deprecated_member_use, long-method
final set = Set(); // LINT
```
### Good:
```dart
// Ignored for some reasons
// ignore: deprecated_member_use
final list = List();

// ignore: deprecated_member_use same line ignore
final queue = Queue();

// ignore: deprecated_member_use, long-method multiple same line ignore
final linkedList = LinkedList();
```
