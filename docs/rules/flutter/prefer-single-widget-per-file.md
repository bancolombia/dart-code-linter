# prefer-single-widget-per-file
added in: 1.6.0 <span style="color: green">style</span>

Warns when a file contains more than a single widget.

Ensures that files have a single responsibility so that each widget exists in its own file.

## Config
Set `ignore-private-widgets` (default is `false`) to ignore private widgets.

```yaml
dart_code_metrics:
  ...
  rules:
    ...
    - prefer-single-widget-per-file:
        ignore-private-widgets: true
```

## Example
### Bad:

some_widgets.dart
```dart
class SomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ...
  }
}

// LINT
class SomeOtherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ...
  }
}

// LINT
class _SomeOtherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ...
  }
}

// LINT
class SomeStatefulWidget extends StatefulWidget {
  @override
  _SomeStatefulWidgetState createState() => _someStatefulWidgetState();
}

class _SomeStatefulWidgetState extends State<InspirationCard> {
  @override
  Widget build(BuildContext context) {
    ...
  }
}
```
### Good:

some_widget.dart
```dart
class SomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ...
  }
}
```
some_other_widget.dart
```dart
class SomeOtherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ...
  }
}
```
