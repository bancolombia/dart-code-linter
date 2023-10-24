# avoid-nested-conditional-expressions
added in: 1.6.0 <span style="color: green">style</span>

Checks for nested conditional expressions.

## Config example
Set `acceptable-level` (default is `1`) to configure the acceptable nesting level.
```yaml
dart_code_linter:
  ...
  rules:
    ...
    - avoid-nested-conditional-expressions:
        acceptable-level: 2
```
## Example
### Bad:
```dart
final str = '';

final oneLevel = str.isEmpty ? 'hi' : '1';

final twoLevels = str.isEmpty
    ? str.isEmpty // LINT
        ? 'hi'
        : '1'
    : '2';

final threeLevels = str.isEmpty
    ? str.isEmpty // LINT
        ? str.isEmpty // LINT
            ? 'hi'
            : '1'
        : '2'
    : '3';
```
### Good:
```dart
final str = '';

final oneLevel = str.isEmpty ? 'hi' : '1';

final twoLevels = _getStr(str);

String _getStr(String str) {
    if (str.isEmpty) {
        return 'hi';
    }

    ...
}
```
