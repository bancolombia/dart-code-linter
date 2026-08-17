// @dart=3.9

enum LogLevel { info, warning, error }

void logMessage(String message, {required LogLevel level}) {}

// Not flagged, although the shape matches the rule: this file's language
// version predates dot shorthands, so the suggested syntax would not compile.
void useNamedArgument() {
  logMessage('failed', level: LogLevel.error);
}
