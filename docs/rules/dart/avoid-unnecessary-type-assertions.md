# avoid-unnecessary-type-assertions
added in: 1.6.0 <span style="color: orange">warning</span>

Warns about unnecessary usage of `is` and `whereType` operators.

## Example
#### Example 1: check is same type
```dart
class Example {
  final myList = <int>[1, 2, 3];

  void main() {
    final result = myList is List<int>; // LINT
    myList.whereType<int>();
  }
}
```
#### Example 2: whereType method
```dart
main(){
  ['1', '2'].whereType<String?>(); // LINT
}
```
#### Example 3: patterns
```dart
class Animal {}

class HomeAnimal extends Animal {}

void main() {
  final animal = Animal();

  if (animal case HomeAnimal result) {}
  if (animal case HomeAnimal()) {}

  if (animal case Animal result) {} // LINT
  if (animal case Animal()) {} // LINT
}
```
