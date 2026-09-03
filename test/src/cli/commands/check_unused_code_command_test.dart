import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/models/unused_code_file_report.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/models/unused_code_issue.dart';
import 'package:dart_code_linter/src/cli/cli_runner.dart';
import 'package:dart_code_linter/src/cli/commands/check_unused_code_command.dart';
import 'package:path/path.dart' as p;
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

UnusedCodeFileReport _report(UnusedCodeIssueKind kind) => UnusedCodeFileReport(
      path: '/project/example.dart',
      relativePath: 'example.dart',
      issues: [
        UnusedCodeIssue(
          declarationName: 'example',
          declarationType: 'method',
          kind: kind,
          location: SourceLocation(1, line: 1, column: 1),
        ),
      ],
    );

const _usage = 'Check unused code in *.dart files.\n'
    '\n'
    'Usage: metrics check-unused-code [arguments] <directories>\n'
    '-h, --help                                       Print this usage information.\n'
    '\n'
    '\n'
    '-r, --reporter=<console>                         The format of the output of the analysis.\n'
    '                                                 [console (default), json]\n'
    '\n'
    '\n'
    '-c, --print-config                               Print resolved config.\n'
    '\n'
    '\n'
    '    --root-folder=<./>                           Root folder.\n'
    '                                                 (defaults to current directory)\n'
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
    '    --[no-]monorepo                              Treat all exported code as unused by default.\n'
    '\n'
    '\n'
    '    --[no-]analyze-private-members               Also report unused private members in type declarations (methods, fields, getters, setters and named constructors).\n'
    '\n'
    '\n'
    '    --[no-]analyze-public-members                Also report unused public members in type declarations. Less reliable than the private members check: members reached only through dynamic calls, reflection or code generation may be reported.\n'
    '\n'
    '\n'
    '    --[no-]suggest-private-members               Also report public declarations that are only referenced from within their own library, and so could be made private. Reports code that is used, not dead code, so it has its own fatal flag.\n'
    '\n'
    '\n'
    '    --[no-]fatal-unused                          Treat find unused code as fatal.\n'
    '                                                 (defaults to on)\n'
    '    --[no-]fatal-could-be-private                Treat finding declarations that could be private as fatal.\n'
    '                                                 (defaults to on)\n'
    '\n'
    'Run "metrics help" to see global options.';

void main() {
  group('CheckUnusedCodeCommand', () {
    final runner = CliRunner();
    final command = runner.commands['check-unused-code'];

    test('should have correct name', () {
      expect(command?.name, equals('check-unused-code'));
    });

    test('should have correct description', () {
      expect(
        command?.description,
        equals('Check unused code in *.dart files.'),
      );
    });

    test('should have correct invocation', () {
      expect(
        command?.invocation,
        equals('metrics check-unused-code [arguments] <directories>'),
      );
    });

    test('should have correct usage', () {
      expect(
        command?.usage.replaceAll('"${p.current}"', 'current directory'),
        equals(_usage),
      );
    });
  });

  group('isFatalUnusedCodeResult', () {
    final unused = [_report(UnusedCodeIssueKind.unused)];
    final suggestion = [_report(UnusedCodeIssueKind.couldBePrivate)];

    bool isFatal(
      Iterable<UnusedCodeFileReport> reports, {
      bool fatalOnUnused = true,
      bool fatalOnCouldBePrivate = true,
    }) =>
        isFatalUnusedCodeResult(
          reports,
          fatalOnUnused: fatalOnUnused,
          fatalOnCouldBePrivate: fatalOnCouldBePrivate,
        );

    test('an empty result is never fatal', () {
      expect(isFatal([]), isFalse);
    });

    test('each kind answers to its own flag', () {
      expect(isFatal(unused), isTrue);
      expect(isFatal(unused, fatalOnUnused: false), isFalse);

      expect(isFatal(suggestion), isTrue);
      expect(isFatal(suggestion, fatalOnCouldBePrivate: false), isFalse);
    });

    test('the flags do not govern the other kind', () {
      // A suggestion is about code that is used, so the dead code gate must
      // not decide it, and the other way round.
      expect(isFatal(suggestion, fatalOnUnused: false), isTrue);
      expect(isFatal(unused, fatalOnCouldBePrivate: false), isTrue);
    });

    test('a mixed result is fatal while either gate is open', () {
      final mixed = [...unused, ...suggestion];

      expect(isFatal(mixed, fatalOnUnused: false), isTrue);
      expect(isFatal(mixed, fatalOnCouldBePrivate: false), isTrue);
      expect(
        isFatal(mixed, fatalOnUnused: false, fatalOnCouldBePrivate: false),
        isFalse,
      );
    });
  });
}
