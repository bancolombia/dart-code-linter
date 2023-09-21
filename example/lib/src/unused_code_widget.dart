import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

/// This variable is not referenced in any file and is actually unused.
/// In order to spot such declarations,
/// run `flutter pub run dart_code_linter:metrics check-unused-code lib`.
const someVariable = '1';

/// This function is not referenced in any file and is actually unused.
/// In order to spot such declarations,
/// run `flutter pub run dart_code_linter:metrics check-unused-code lib`.
String topLevelFunction() {
  print('Actually unused');

  return 'Unused';
}

/// This widget is used by `main.dart`.
class UnusedCodeWidget extends StatelessWidget {
  const UnusedCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
