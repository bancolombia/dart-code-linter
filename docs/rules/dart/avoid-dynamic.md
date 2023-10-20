# avoid-dynamic
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when the `dynamic` type is used as a variable type in a declaration, return type of a function, etc. Using `dynamic` is considered unsafe since it can easily result in runtime errors.

:::info
Using the `dynamic` type for a `Map<>` is considered fine, since there is no better way to declare a type of a JSON payload.
:::

## Example
### Bad:
```dart
dynamic x = 10; // LINT

// LINT
String concat(dynamic a, dynamic b) {
  return a + b;
}

(dynamic,) _getValue() => (null, ); // LINT
```
### Good:
```dart
int x = 10;

final x = 10;

String concat(String a, String b) {
  return a + b;
}

(int?,) _getValue() => (null, ); // LINT
```
