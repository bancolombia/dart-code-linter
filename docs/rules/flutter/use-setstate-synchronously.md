# use-setstate-synchronously
added in: 1.6.0 <span style="color: orange">warning</span>

Warns when <code>[setState](https://api.flutter.dev/flutter/widgets/State/setState.html)</code> is called past an <i>await point</i> (also known as asynchronous gap) within a subclass of State.

In async functions, the state of a widget may have been disposed between await points, e.g. because the user moved to another screen, leading to errors calling <code>[setState](https://api.flutter.dev/flutter/widgets/State/setState.html)</code>. After each await point, i.e. when a Future is awaited, the possibility that the widget has been unmounted needs to be checked before calling <code>[setState](https://api.flutter.dev/flutter/widgets/State/setState.html)</code>.

Consider storing Futures directly in your state and use <code>[FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)</code> to unwrap them.

If this is not possible, you can also check for <code>[mounted](https://api.flutter.dev/flutter/widgets/State/mounted.html)</code> to only update state when the widget is still mounted. However, an effective fix usually does not make use of <code>[mounted](https://api.flutter.dev/flutter/widgets/State/mounted.html)</code>, but rather revolves around refactoring your states.

:::info
The following patterns are recognized when statically determining mountedness:

- `if (mounted)`
- `if (mounted && ..)`
- `if (!mounted || ..)`
- `try` and `switch` mountedness per branch
- Divergence in `for`, `while` and `switch` statements using `break` or `continue`
If a `!mounted` check diverges, i.e. ends in a `return` or `throw`, the outer scope is considered mounted and vice versa:

```dart
if (!mounted) return;
// Should be mounted right now
setState(() { ... });

// After this statement, need to check 'mounted' again
await fetch(...);

// In control flow statements, 'break' and 'continue' diverges
while (...) {
  if (!mounted) break;
  // Should be mounted right now
  setState(() { ... });
}
```
:::

Additional resources:

- https://stackoverflow.com/questions/49340116/setstate-called-after-dispose
- <code>[use_build_context_synchronously](https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html)</code>, a lint that checks for async usages of `BuildContext`

## Config
Set `methods` (default is <code>[setState](https://api.flutter.dev/flutter/widgets/State/setState.html)</code>) to configure the list of methods to check for unchecked async calls.
```yaml
dart_code_metrics:
  ...
  rules:
    ...
    - use-setstate-synchronously:
        methods:
          - setState
          - yourMethod
```
## Example
### Bad:
```dart
class _MyWidgetState extends State<MyWidget> {
  String message;

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () async {
        String fromServer = await fetch(...);
        // LINT
        setState(() {
          message = fromServer;
        });
      },
      child: Text(message),
    );
  }
}
```
### Good:
```dart
class _MyWidgetState extends State<MyWidget> {
  String message;

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () async {
        String fromServer = await fetch(...);
        if (mounted) {
          setState(() {
            message = fromServer;
          });
        }
      },
      child: Text(message),
    );
  }
}
```
### Good:
```dart
class _MyWidgetState extends State<MyWidget> {
  Future<String> message;

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () {
        setState(() {
          message = fetch(...);
        });
      },
      child: FutureBuilder<String>(
        future: message,
        builder: (context, snapshot) {
          return Text(snapshot.data ?? "...");
        },
      ),
    );
  }
}
```
