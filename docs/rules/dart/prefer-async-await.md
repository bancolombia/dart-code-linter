# prefer-async-await
added in: 1.6.0 <span style="color: green">style</span>

Recommends to use async/await syntax to handle Futures result instead of `.then()` invocation. Also can help prevent errors with mixed await and `.then()` usages, since awaiting the result of a `Future` with `.then()` invocation awaits the completion of `.then()`.

## Example
### Bad:
```dart
Future<void> main() async {
  someFuture.then((result) => handleResult(result)); // LINT

  await (foo.asyncMethod()).then((result) => handleResult(result)); // LINT
}
```
### Good:
```dart
Future<void> main() async {
  final result = await someFuture;
  handleResult(result);

  final anotherResult = await foo.asyncMethod();
  handleResult(anotherResult);
}
```
