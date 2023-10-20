# avoid-initializing-in-on-mount
added in: 1.6.0 <span style="color: orange">warning</span>.

Warns when a `late final` variable is being initialized in the Component's `onMount` method.

Since a Component might be removed and added again, attempt to reinitialize a late final variable will result in runtime exception.

## Example
### Bad:
```dart
class MyComponent extends Component {
  late final int x;

  @override
  void onMount() {
    x = 1; // LINT
  }
}
```
### Good:
```dart
class MyComponent extends Component {
  int x;

  @override
  void onMount() {
    x = 1;
  }
}
```
