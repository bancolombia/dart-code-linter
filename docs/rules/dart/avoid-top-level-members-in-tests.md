# avoid-top-level-members-in-tests
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when a public top-level member (expect the entrypoint) is declared inside a test file.

It helps reduce code bloat and find unused declarations in test files.

::: note
If you want to set exclude config for this rule, the default [`'lib/**', 'bin/**'`] will be overriden.
:::

## Example
### Bad:
```dart
final public = 1; // LINT

void function() {} // LINT

class Class {} // LINT

mixin Mixin {} // LINT

extension Extension on String {} // LINT

enum Enum { first, second } // LINT

typedef Public = String; // LINT
```
### Good:
```dart
final _private = 2;

void _function() {}

class _Class {}

mixin _Mixin {}

extension _Extension on String {}

enum _Enum { first, second }

typedef _Private = String;
```
