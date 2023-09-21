import 'package:flutter/widgets.dart';

/// This widget is not imported by any other file and is not a project entry point.
/// It will be reported by `check-unused-files` command.
/// Run `flutter pub run dart_code_linter:metrics check-unused-files lib` to see the report.
class UnusedWidget extends StatelessWidget {
  const UnusedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
