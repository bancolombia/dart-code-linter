import 'package:flutter/material.dart';
import 'package:flutter_example/src/unnecessary_nullable_widget.dart';
import 'package:flutter_example/src/unused_code_widget.dart';

void main() {
  runApp(const MyApp());
}

/// The issue below is reported by Dart Code Linter.
/// In order to resolve the warning, the class or the file should be renamed.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  /// The issue below is reported by Dart Code Linter.
  /// In order to resolve the warning, the parameter should be used or removed.
  void _incrementCounter(BuildContext context) {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            UnusedCodeWidget(),
            UnnecessaryNullableWidget(),
          ],
        ),
      ),

      /// The issue below is reported by Dart Code Linter. The severity of a rule can be configured via `severity` config entry.
      /// Adding a trailing comma will remove the highlight.
      /// Trailing comma can also be added with auto-fix menu command in the IDE.
      /// Rules that support auto-fixes are marked with corresponding emoji in the docs https://dartcodemetrics.dev/docs/rules.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _incrementCounter(context),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ));
}
