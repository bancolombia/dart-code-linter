# avoid-redundant-async-on-load
added in: 1.6.0 <span style="color: orange">warning</span>.

Warns when a Component's `onLoad` method can be made sync.

Refactoring async onLoad to sync helps Flame directly continue in it's loading cycle.

## Example
### Bad:
```dart
class MyComponent extends Component {
  Future<void> onLoad() async {
    ... // LINT, has no await
  }
}
```
### Good:
```dart
class MyComponent extends Component {
  Future<void> onLoad() async {
    await ...
  }
}

class MyComponent extends Component {
  void onLoad() {
    ...
  }
}
```
