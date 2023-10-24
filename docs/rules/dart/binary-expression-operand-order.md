# binary-expression-operand-order
added in: 1.6.0 <span style="color: green">style</span>

Warns when a literal value is on the left hand side in a binary expressions.

### Bad:
```dart
final a = 1 + b;
```
### Good:
```dart
final a = b + 1;
```
