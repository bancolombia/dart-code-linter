# avoid-throw-in-catch-block
added in: 1.6.0 <span style="color: orange">warning</span>

Call throw in a catch block loses the original stack trace and the original exception.

Since 2.16 version you can use [Error.throwWithStackTrace](https://api.dart.dev/dev/2.16.0-9.0.dev/dart-core/Error/throwWithStackTrace.html).

## Example
```dart
void repository() {
  try {
    networkDataProvider();
  } on Object {
    throw RepositoryException(); // LINT
  }
}
```
