# prefer-extracting-callbacks
added in: 1.6.0 <span style="color: green">style</span>

Warns about inline callbacks in a widget tree and suggests to extract them to widget methods in order to make a build method more readable. In addition extracting can help test those methods separately as well.

:::info
This rule will not trigger on:

- arrow functions like `onPressed: () => _handler(...)` in order to cover cases when a callback needs a variable from the outside;
- empty blocks.
- Flutter specific: arguments with functions returning `Widget` type (or its subclass) and with first parameter of type `BuildContext`. "Builder" functions is a common pattern in Flutter, for example, <u>[IndexedWidgetBuilder](https://api.flutter.dev/flutter/widgets/IndexedWidgetBuilder.html)</u> typedef is used in <u>[ListView.builder](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html)</u>.:::

## Config
Set `allowed-line-count` (default is none) to configure the maximum number of lines after which the rule should trigger.

Set `ignored-named-arguments` (default is none) to ignore specific named parameters.

```yaml
dart_code_metrics:
  ...
  rules:
    ...
    - prefer-extracting-callbacks:
        ignored-named-arguments:
          - onPressed
        allowed-line-count: 3
```
## Example
### Bad:
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ...,
      onPressed: () { // LINT
        // Some
        // Huge
        // Callback
      },
      child: ...
    );
  }
}
```
### Good:
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ...,
      onPressed: () => handlePressed(context),
      child: ...
    );
  }

  void handlePressed(BuildContext context) {
    ...
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ...,
      onPressed: handlePressed,
      child: ...
    );
  }

  void handlePressed() {
    ...
  }
}
```
