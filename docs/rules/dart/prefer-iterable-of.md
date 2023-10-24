# prefer-iterable-of
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when `List.from()` factory is used instead of `List.of()`.

The difference between `List.of()` and `List.from()` is that `.of()` takes an argument of the same type as what it returns and enforces it at compilation time, and that `.from()` allows potentially unsafe downcasting and enforces convertibility at runtime.

Additional resources:

- https://github.com/dart-lang/linter/issues/2555
- https://github.com/dart-lang/linter/issues/2066

## Example
### Bad:
```dart
...
var intList = [1, 2, 3];

var copy = List<int>.from(intList); // LINT
var numList = List<num>.from(intList); // LINT

var unspecifiedList = List.from(intList); // LINT

final recordsSet = <(num,)>{(1,), (2,), (3,)};
final recordSet = Set<(num,)>.from(recordsSet); // LINT
final extra = Set<(int, String)>.from(recordsSet); // LINT
```
### Good:
```dart
var intList = [1, 2, 3];

var copy = List<int>.of(intList);
var numList = List<num>.of(intList);
...

var numList = <num>[1, 2, 3];

var intList = List<int>.from(numList);

final recordsSet = <(num,)>{(1,), (2,), (3,)};
final record = Set<(int,)>.from(recordsSet);
```
