# avoid-unnecessary-type-casts
added in: 1.6.0 <span style="color: orange">warning</span>

Warns about of unnecessary use of casting operators.

## Example
```dart
class Example {
  final myList = <int>[1, 2, 3];

  void main() {
    final result = myList as List<int>; // LINT
  }
}

class Animal {}

class HomeAnimal extends Animal {}

void patterns() {
  final animal = Animal();

  if (animal case Animal() as HomeAnimal) {}
  if (animal case Animal() as Animal) {} // LINT
}
```
