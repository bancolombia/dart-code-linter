# no-equal-arguments
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when equal arguments passed to a function or method invocation.

## Config
Set `ignored-parameters` (default is none) to ignore specific named parameters.

Set `ignored-arguments` (default is none) to ignore specific argument names.

Set `ignore-inline-functions` (default is `false`) to ignore inline functions that are passed as arguments.
```yaml
dart_code_linter:
  ...
  rules:
    ...
    - no-equal-arguments:
        ignored-parameters:
          - height
          - width
```
## Example
### Bad:
```dart
class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);
}

User createUser(String firstName, String lastName)  {
  return User(
    firstName,
    firstName, // LINT
  );
}

void getUserData(User user) {
  String getFullName(String firstName, String lastName) {
    return firstName + ' ' + lastName;
  }

  final fullName = getFullName(
    user.firstName,
    user.firstName, // LINT
  );
}
```
### Good:
```dart
class User {
  final String firstName;
  final String lastName;

  const User(this.firstName, this.lastName);
}

User createUser(String firstName, String lastName)  {
  return User(
    firstName,
    lastName,
  );
}

void getUserData(User user) {
  String getFullName(String firstName, String lastName) {
    return firstName + ' ' + lastName;
  }

  final fullName = getFullName(
    user.firstName,
    user.lastName,
  );
}
```
