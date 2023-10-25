# avoid-passing-async-when-sync-expected
added in: 1.6.0 <span style="color: orange">warning</span>

Avoid passing asynchronous function as an argument where a synchronous function is expected.

:::note
For this rule it's recommended to exclude the `test` folder.
:::

## Example
### Bad:
```dart
void doSomethingWithCallback(VoidCallback function) {
  ...
  function();
  ...
}

void main() {
  doSomethingWithCallback(() async {
    await Future.delayed(Duration(seconds: 1));
    print('Hello World');
  });
}
```
### Good:
```dart
void doSomethingWithCallback(VoidCallback function) {
  ...
  function();
  ...
}

void main() {
  doSomethingWithCallback(() {
    print('Hello World');
  });
}
```
