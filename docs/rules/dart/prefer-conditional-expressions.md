# prefer-conditional-expressions
added in: 1.6.0 <span style="color: green">style</span>

Recommends to use a conditional expression instead of assigning to the same thing or return statement in each branch of an if statement.

## Config example
Set `ignore-nested` (default is `false`) to ignore cases with multiple nested conditional expressions.
```yaml
dart_code_linter:
  ...
  rules:
    ...
    - prefer-conditional-expressions:
        ignore-nested: true
```
## Example
### Bad:
```dart
  int a = 0;

  // LINT
  if (a > 0) {
    a = 1;
  } else {
    a = 2;
  }

  // LINT
  if (a > 0) a = 1;
  else a = 2;

  int function() {
    // LINT
    if (a == 1) {
        return 0;
    } else {
        return 1;
    }

    // LINT
    if (a == 2) return 0;
    else return 1;
  }
```
### Good:
```dart
  int a = 0;

  a = a > 0 ? 1 : 2;

  int function() {
    return a == 2 ? 0 : 1;
  }
```
