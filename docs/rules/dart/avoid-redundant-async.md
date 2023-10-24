# avoid-redundant-async
added in: 1.6.0 <span style="color: orange">warning</span>

Checks for redundant `async` in a method or function body.

Cases where `async` is useful include:

- The function body has `await`.
- An error is returned asynchronously. `async` and then `throw` is shorter than return `Future.error(...)`.
- A value is returned and it will be implicitly wrapped in a future. `async` is shorter than `Future.value(...)`.

Additional resources:

- https://dart.dev/guides/language/effective-dart/usage#dont-use-async-when-it-has-no-useful-effect

## Example
### Bad:
```dart
Future<void> afterTwoThings(Future<void> first, Future<void> second) async {
  return Future.wait([first, second]);
}
```
### Good:
```dart
Future<void> usesAwait(Future<String> later) async {
  print(await later);
}

Future<void> asyncError() async {
  throw 'Error!';
}

Future<void> asyncValue() async => 'value';
```