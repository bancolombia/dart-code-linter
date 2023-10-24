# avoid-non-ascii-symbols
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when a string literal contains non ascii characters. This might indicate that the string was not localized.

## Example
### Bad:
```dart
final chinese = 'hello 汉字'; // LINT
final russian = 'hello привет'; // LINT
final withSomeNonAsciiSymbols = '#!$_&-  éè  ;∞¥₤€'; // LINT
final misspelling = 'inform@tiv€'; // LINT
```
### Good:
```dart
final english = 'hello';
final someGenericSymbols ='!@#$%^';
```
