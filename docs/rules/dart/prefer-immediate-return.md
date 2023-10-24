# prefer-immediate-return
added in: 1.6.0 <span style="color: green">style</span>

Declaring a local variable only to immediately return it might be considered a bad practice. The name of a function or a class method with its return type should give enough information about what should be returned.

## Example
### Bad:
```dart
void calculateSum(int a, int b) {
    final sum = a + b;
    return sum; // LINT
}

void calculateArea(int width, int height) {
    final result = width * height;
    return result; // LINT
}
```
### Good:
```dart
void calculateSum(int a, int b) {
    return a + b;
}

void calculateArea(int width, int height) => width * height;
```
