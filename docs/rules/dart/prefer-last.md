# prefer-last
added in: 1.6.0 <span style="color: green">style</span>

Warns when the last element of an Iterable is accessed by `iterable[iterable.length - 1]` or `iterable.elementAt(iterable.length - 1)` instead of calling `iterable.last`.

## Example
### Bad:
```dart
...
const list = [1, 2, 3, 4, 5, 6, 7, 8, 9];

list.elementAt(list.length - 1); // LINT
list[list.length - 1]; // LINT
```
### Good:
```dart
const list = [1, 2, 3, 4, 5, 6, 7, 8, 9];

list.last;
```
