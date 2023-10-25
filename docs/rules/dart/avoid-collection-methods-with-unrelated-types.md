# avoid-collection-methods-with-unrelated-types

added in: 1.6.0 <span style="color: orange">warning</span>.

Avoid using collection methods with unrelated types, such as accessing a map of integers using a string key.

:::info
This lint has been requested for a long time: Follow <u>[this link](https://github.com/dart-lang/linter/issues/1307)</u> this link to see the details.
Related: Dart's built-in `list_remove_unrelated_type` and `iterable_contains_unrelated_type`. :::

Use strict configuration (default is true), if you want dynamic or Object type keys to not trigger the warning.

## Config example
```dart:
dart_code_linter:
  ...
  rules:
    ...
    - avoid-collection-methods-with-unrelated-types:
        strict: false
```
## Example

### Bad:

```dart
final map = Map<int, String>();
map["str"] = "value"; // LINT
var a = map["str"]; // LINT
map.containsKey("str"); // LINT
map.containsValue(42); // LINT
map.remove("str"); // LINT

Iterable<int>.empty().contains("str"); // LINT

List<int>().remove("str"); // LINT

final set = {10, 20, 30};
set.contains("str"); // LINT
set.containsAll(Iterable<String>.empty()); // LINT
set.difference(<String>{}); // LINT
primitiveSet.intersection(<String>{}); // LINT
set.lookup("str"); // LINT
primitiveList.remove("str"); // LINT
set.removeAll(Iterable<String>.empty()); // LINT
set.retainAll(Iterable<String>.empty()); // LINT
```

### Good:

```dart
final map = Map<int, String>();
map[42] = "value";
var a = map[42];
map.containsKey(42);
map.containsValue("value");
map.remove(42);

Iterable<int>.empty().contains(42);

List<int>().remove(42);

final set = {10, 20, 30};
set.contains(42);
set.containsAll(Iterable<int>.empty());
set.difference(<int>{});
primitiveSet.intersection(<int>{});
set.lookup(42);
primitiveList.remove(42);
set.removeAll(Iterable<int>.empty());
set.retainAll(Iterable<int>.empty());
```
