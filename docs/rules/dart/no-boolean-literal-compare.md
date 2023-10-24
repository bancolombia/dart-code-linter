# no-boolean-literal-compare
added in: 1.5.0 <span style="color: green">style</span>

Warns on comparison to a boolean literal, as in `x == true`. Comparing boolean values to boolean literals is unnecessary, as those expressions will result in booleans too. Just use the boolean values directly or negate them.

## Config
Set allow-false (default is false) to allow value == false or false == value checks.
```yaml
dart_code_linter:
  ...
  rules:
    ...
    - no-boolean-literal-compare:
        allow-false: true
```
## Example
### Bad:
```dart
  var b = x == true; // LINT
  var c = x != true; // LINT

   // LINT
  if (x == true) {
    ...
  }

   // LINT
  if (x != false) {
    ...
  }
```
### Good:
```dart
  var b = x;
  var c = !x;

  if (x) {
    ...
  }

  if (!x) {
    ...
  }
```
