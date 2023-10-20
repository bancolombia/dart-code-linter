# avoid-wrapping-in-padding
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when a widget is wrapped in a `Padding` widget but has a padding settings by itself.

## Example
### Bad:
```dart
class CoolWidget {
  ...

  Widget build(...) {
    // LINT
    return Padding(
      child: Container(),
    );
  }
}
```
### Good:
```dart
class CoolWidget {
  Widget build() {
    return Container();
  }
}

class AnotherWidget {
  Widget build() {
    return Padding(
      child: Icon();
    );
  }
}
```
