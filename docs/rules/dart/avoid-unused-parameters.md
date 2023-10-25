# avoid-unused-parameters
added in: 1.6.0 <span style="color: orange">warning</span>

Checks for unused parameters inside a function or method body. For overridden methods suggests renaming unused parameters to _, __, etc.

:::caution
Abstract classes are completely ignored by the rule to avoid redundant checks for potentially overridden methods.
:::

## Config
Set `ignore-inline-functions` (default is `true`) to ignore inline functions. Default value is set to `true` for backward compatibility and can be changed in the future.
```yaml
dart_code_linter:
  ...
  rules:
    ...
    - avoid-unused-parameters:
        ignore-inline-functions: false
```
## Example
### Bad:
```dart
void someFunction(String s) { // LINT
  return;
}

class SomeClass {
  void method(String s) { // LINT
    return;
  }
}

class SomeClass extends AnotherClass {
  @override
  void method(String s) {} // LINT
}
```
### Good:
```dart
void someOtherFunction() {
  return;
}

class SomeOtherClass {
  void method() {
    return;
  }
}

void someOtherFunction(String s) {
  print(s);
  return;
}

class SomeOtherClass {
  void method(String s) {
    print(s);
    return;
  }
}

class SomeOtherClass extends AnotherClass {
  @override
  void method(String _) {}
}

abstract class SomeOtherClass {
  void method(String s);
}
```
