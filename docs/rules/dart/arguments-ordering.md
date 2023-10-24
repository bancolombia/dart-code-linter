# arguments-ordering

Enforces named argument order in function and constructor invocations to be the same as corresponding named parameter declaration order.

## Config
Set child-last (default is false) to keep the child property last.

This option allows you to use this rule together with [sort_child_properties_last](https://dart.dev/tools/linter-rules/sort_child_properties_last).

```dart:
dart_code_linter:
  ...
  rules:
    ...
    - arguments-ordering:
        child-last: true
```

## Example

### Bad:
```dart:
Person buildPerson({ String name, String surname, String age });

// LINT
final person = buildPerson(age: 42, surname: 'The Pooh', name: 'Winnie');
```

### Good:
```dart:
Person buildPerson({ String name, String surname, String age });

final person = buildPerson(name: 'Winnie', surname: 'The Pooh', age: 42);
```
