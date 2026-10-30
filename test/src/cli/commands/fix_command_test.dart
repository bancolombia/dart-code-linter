import 'package:dart_code_linter/src/cli/cli_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _usage =
    'Automatically fix code issues based on lint rules and metrics.\n'
    '\n'
    'Usage: metrics fix [arguments] [<directories>]\n'
    '-h, --help                                       Print this usage information.\n'
    '\n'
    '\n'
    '-r, --reporter=<console>                         The format of the output of the analysis.\n'
    '                                                 [console (default), console-verbose, checkstyle, codeclimate, github, gitlab, html, json]\n'
    '-o, --output-directory=<OUTPUT>                  Write HTML output to OUTPUT.\n'
    '                                                 (defaults to "metrics")\n'
    '    --json-path=<path/to/file.json>              Path to the JSON file with the output of the analysis.\n'
    '\n'
    '\n'
    '-c, --print-config                               Print resolved config.\n'
    '\n'
    '\n'
    '    --root-folder=<./>                           Root folder.\n'
    '                                                 (defaults to current directory)\n'
    '    --workspace                                  Add each Pub workspace package lib directory to the targets.\n'
    '    --sdk-path=<directory-path>                  Dart SDK directory path. Should be provided only when you run the application as compiled executable(https://dart.dev/tools/dart-compile#exe) and automatic Dart SDK path detection fails.\n'
    '    --exclude=<{/**.g.dart,/**.freezed.dart}>    File paths in Glob syntax to be exclude.\n'
    '                                                 (defaults to "{/**.g.dart,/**.freezed.dart}")\n'
    '\n'
    '\n'
    "    --no-congratulate                            Don't show output even when there are no issues.\n"
    '\n'
    '\n'
    '    --[no-]verbose                               Show verbose logs.\n'
    '\n'
    '\n'
    '    --set-exit-on-violation-level=<warning>      Set exit code 2 if code violations same or higher level than selected are detected.\n'
    '                                                 [noted, warning, alarm]\n'
    '    --[no-]fatal-style                           Treat style level issues as fatal.\n'
    '    --[no-]fatal-performance                     Treat performance level issues as fatal.\n'
    '    --[no-]fatal-warnings                        Treat warning level issues as fatal.\n'
    '                                                 (defaults to on)\n'
    '\n'
    'Run "metrics help" to see global options.';

void main() {
  group('FixCommand', () {
    final runner = CliRunner();
    final command = runner.commands['fix'];

    test('should have correct name', () {
      expect(command?.name, equals('fix'));
    });

    test('should have correct description', () {
      expect(
        command?.description,
        equals(
            'Automatically fix code issues based on lint rules and metrics.'),
      );
    });

    test('should have correct invocation', () {
      expect(
        command?.invocation,
        equals('metrics fix [arguments] [<directories>]'),
      );
    });

    test('should have correct usage', () {
      expect(
        command?.usage.replaceAll('"${p.current}"', 'current directory'),
        equals(_usage),
      );
    });
  });
}
