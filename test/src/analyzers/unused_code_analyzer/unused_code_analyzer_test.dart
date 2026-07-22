import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/models/unused_code_file_report.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/reporters/reporters_list/console/unused_code_console_reporter.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/unused_code_analyzer.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/unused_code_config.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group(
    'UnusedCodeAnalyzer',
    () {
      const analyzer = UnusedCodeAnalyzer();
      const rootDirectory = '';
      const analyzerExcludes = [
        'test/resources/unused_code_analyzer/generated/**',
      ];
      final folders = [
        normalize(File('test/resources/unused_code_analyzer').absolute.path),
      ];

      group('run analysis', () {
        late Iterable<UnusedCodeFileReport> result;

        setUpAll(() async {
          final config =
              _createConfig(analyzerExcludePatterns: analyzerExcludes);

          result = await analyzer.runCliAnalysis(
            folders,
            rootDirectory,
            config,
          );
        });

        test('should report 5 files and not report excluded file', () {
          expect(result, hasLength(5));
        });

        test('should analyze not used files', () async {
          final report = result
              .firstWhere((report) => report.path.endsWith('not_used.dart'));

          expect(report.issues, hasLength(3));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'NotUsed');
          expect(firstIssue.declarationType, 'class');
          expect(firstIssue.location.line, 1);
          expect(firstIssue.location.column, 1);

          final secondIssue = report.issues.elementAt(1);
          expect(secondIssue.declarationName, 'value');
          expect(secondIssue.declarationType, 'top level variable');
          expect(secondIssue.location.line, 3);
          expect(secondIssue.location.column, 1);

          final thirdIssue = report.issues.elementAt(2);
          expect(thirdIssue.declarationName, 'someFunction');
          expect(thirdIssue.declarationType, 'function');
          expect(thirdIssue.location.line, 6);
          expect(thirdIssue.location.column, 1);
        });

        test('should analyze conditional import files', () async {
          final unconditionalReport = result.firstWhereOrNull(
            (report) => report.path.endsWith('unconditional_file.dart'),
          );

          expect(unconditionalReport, null);

          final report = result.firstWhere(
            (report) => report.path.endsWith('conditional_file.dart'),
          );

          expect(report.issues, hasLength(1));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'hello');
          expect(firstIssue.declarationType, 'function');
          expect(firstIssue.location.line, 6);
          expect(firstIssue.location.column, 1);
        });

        test('should analyze conditional prefixed import files', () async {
          final unconditionalReport = result.firstWhereOrNull(
            (report) =>
                report.path.endsWith('unconditional_prefixed_file.dart'),
          );

          expect(unconditionalReport, null);

          final report = result.firstWhere(
            (report) => report.path.endsWith('conditional_prefixed_file.dart'),
          );

          expect(report.issues, hasLength(1));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'helloWorld');
          expect(firstIssue.declarationType, 'function');
          expect(firstIssue.location.line, 3);
          expect(firstIssue.location.column, 1);
        });

        test('should analyze files', () async {
          final report = result.firstWhere(
            (report) => report.path.endsWith('public_members.dart'),
          );

          expect(report.issues, hasLength(8));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'printInteger');
          expect(firstIssue.declarationType, 'function');
          expect(firstIssue.location.line, 4);
          expect(firstIssue.location.column, 1);

          final secondIssue = report.issues.elementAt(1);
          expect(secondIssue.declarationName, 'someVariable');
          expect(secondIssue.declarationType, 'top level variable');
          expect(secondIssue.location.line, 13);
          expect(secondIssue.location.column, 1);

          final thirdIssue = report.issues.elementAt(2);
          expect(thirdIssue.declarationName, 'SomeClassWithMethod');
          expect(thirdIssue.declarationType, 'class');
          expect(thirdIssue.location.line, 97);
          expect(thirdIssue.location.column, 1);

          final forthIssue = report.issues.elementAt(3);
          expect(forthIssue.declarationName, 'SomeOtherService');
          expect(forthIssue.declarationType, 'class');
          expect(forthIssue.location.line, 123);
          expect(forthIssue.location.column, 1);

          final fifthIssue = report.issues.elementAt(4);
          expect(fifthIssue.declarationName, 'IntX');
          expect(fifthIssue.declarationType, 'extension');
          expect(fifthIssue.location.line, 144);
          expect(fifthIssue.location.column, 1);

          final sixthIssue = report.issues.elementAt(5);
          expect(sixthIssue.declarationName, 'SomeOtherEnum');
          expect(sixthIssue.declarationType, 'enum');
          expect(sixthIssue.location.line, 153);
          expect(sixthIssue.location.column, 1);

          final seventhIssue = report.issues.elementAt(6);
          expect(seventhIssue.declarationName, 'World');
          expect(seventhIssue.declarationType, 'type alias');
          expect(seventhIssue.location.line, 162);
          expect(seventhIssue.location.column, 1);

          final eightsIssue = report.issues.elementAt(7);
          expect(eightsIssue.declarationName, 'MyOtherWidget');
          expect(eightsIssue.declarationType, 'class');
          expect(eightsIssue.location.line, 171);
          expect(eightsIssue.location.column, 1);
        });

        test('should analyze elements from incorrectly parsed library', () {
          final report = result.firstWhere(
            (report) => report.path.endsWith('app_icons.dart'),
          );

          expect(report.issues, hasLength(1));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'AppIcons');
          expect(firstIssue.declarationType, 'class');
          expect(firstIssue.location.line, 3);
          expect(firstIssue.location.column, 1);
        });
      });

      test('should return a reporter', () {
        final reporter = analyzer.getReporter(name: 'console', output: stdout);

        expect(reporter, isA<UnusedCodeConsoleReporter>());
      });

      group('analyze-private-members', () {
        final privateMembersFolders = [
          normalize(File('test/resources/unused_code_private_members_analyzer')
              .absolute
              .path),
        ];

        test('is disabled by default', () async {
          final result = await analyzer.runCliAnalysis(
            privateMembersFolders,
            rootDirectory,
            _createConfig(),
          );

          expect(result, isEmpty);
        });

        test('reports only unused private members when enabled', () async {
          final result = await analyzer.runCliAnalysis(
            privateMembersFolders,
            rootDirectory,
            _createConfig(analyzePrivateMembers: true),
          );

          final report = result.firstWhere(
            (report) => report.path.endsWith('private_members.dart'),
          );

          final names = report.issues.map((issue) => issue.declarationName);

          expect(
            names,
            unorderedEquals([
              '_unusedField',
              '_unusedMethod',
              '_unusedGetter',
              '_unusedExtensionGetter',
              '_unusedExtensionMethod',
            ]),
          );
          expect(names, isNot(contains('publicUnusedMethod')));
          expect(names, isNot(contains('_usedField')));
          expect(names, isNot(contains('_usedMethod')));
          expect(names, isNot(contains('_usedGetter')));
          expect(names, isNot(contains('_usedExtensionGetter')));
          expect(names, isNot(contains('_usedExtensionMethod')));
        });

        test(
          'known limitation: a dead private override sharing a name with a '
          'live ancestor member is not reported (see private_override.dart)',
          () async {
            final result = await analyzer.runCliAnalysis(
              privateMembersFolders,
              rootDirectory,
              _createConfig(analyzePrivateMembers: true),
            );

            final report = result.firstWhereOrNull(
              (report) => report.path.endsWith('private_override.dart'),
            );

            // Derived2 is instantiated (so the class itself isn't flagged),
            // but Derived2._template2 is never called on it and is
            // genuinely dead. It is NOT flagged: the name+library fallback
            // in _isEqualElements treats it as used because Base2._template2
            // (same name, same library) is used elsewhere. Tracked as a
            // known limitation, not a regression to fix here. A file with no
            // issues at all is omitted from the result set entirely.
            expect(report, null);
          },
        );
      });
    },
    testOn: 'posix',
  );
}

UnusedCodeConfig _createConfig({
  Iterable<String> analyzerExcludePatterns = const [],
  bool analyzePrivateMembers = false,
}) =>
    UnusedCodeConfig(
      excludePatterns: const [],
      analyzerExcludePatterns: analyzerExcludePatterns,
      isMonorepo: false,
      shouldPrintConfig: false,
      analyzePrivateMembers: analyzePrivateMembers,
    );
