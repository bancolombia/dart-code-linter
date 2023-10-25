# avoid-non-null-assertion
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when non null assertion operator (! or “bang” operator) is used for a property access or method invocation. The operator check works at runtime and it may fail and throw a runtime exception.

The rule ignores the index `[]` operator on the Map class because it's considered the idiomatic way to access a known-present element in a map with `[]!` according to [the docs](https://dart.dev/null-safety/understanding-null-safety#the-map-index-operator-is-nullable).

:::note
Use this rule if you want to avoid possible unexpected runtime exceptions.
:::

## Config
Set `skip-checked-fields` (default is `false`) to allow non-null assertions on fields that are checked to be non-null within an if statement.
```yaml
dart_code_linter:
  ...
  rules:
    ...
    - avoid-non-null-assertion:
        skip-checked-fields: true
```
## Example
### Bad:
```dart
class Test {
  String? field;

  Test? object;

  void method() {
    field!.contains('other'); // LINT

    object!.field!.contains('other'); // LINT

    final map = {'key': 'value'};
    map['key']!.contains('other');

    object!.method(); // LINT

    if (object case int!) { // LINT
      // ...
    }
  }
}
```
### Good:
```dart
class Test {
  String? field;

  Test? object;

  void method() {
    field?.contains('other');

    object?.field?.contains('other');

    final map = {'key': 'value'};
    map['key']!.contains('other');

    object?.method();
  }
}
```
