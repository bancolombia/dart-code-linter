import 'package:flutter/material.dart';

class UnnecessaryNullableWidget extends StatelessWidget {
  const UnnecessaryNullableWidget({super.key});

  /// This callback declares a nullable parameter `value`,
  /// but it's actually always used with non-nullable argument.
  /// Run `flutter pub run dart_code_linter:metrics check-unnecessary-nullable lib` to see the report.
  void someCallback(String? value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => someCallback('Hello'),
      child: Text('From world'),
    );
  }
}
