# prefer-correct-test-file-name
added in: 1.6.0 <span style="color: orange">warning</span>

Warns if the file within `/test` contains a `main`, but the file name doesn't end with `_test.dart`.

:::note
If you want to set `exclude` config for this rule, the default [`'lib/**', 'bin/**'`] will be overriden.
:::

## Example
### Bad:
```dart
File name: some_file.dart

void main() {
  ...
}
```
### Good:
```dart
File name: some_file_test.dart

void main() {
  ...
}

File name: some_other_file.dart

void helperFunction() {
  ...
}
```
