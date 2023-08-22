import 'dart:isolate';

import 'package:dart_code_linter/analyzer_plugin.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
