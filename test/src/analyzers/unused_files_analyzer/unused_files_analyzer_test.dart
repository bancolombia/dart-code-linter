import 'dart:io';

import 'package:dart_code_linter/src/analyzers/unused_files_analyzer/reporters/reporters_list/console/unused_files_console_reporter.dart';
import 'package:dart_code_linter/src/analyzers/unused_files_analyzer/unused_files_analyzer.dart';
import 'package:dart_code_linter/src/analyzers/unused_files_analyzer/unused_files_config.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../generated_usages_project.dart';

void main() {
  group(
    'UnusedFilesAnalyzer',
    () {
      const analyzer = UnusedFilesAnalyzer();
      const rootDirectory = '';
      const analyzerExcludes = [
        'test/resources/**',
        'test/resources/unused_files_analyzer/generated/**/**',
        'test/**/examples/**',
      ];
      final folders = [
        normalize(File('test/resources/unused_files_analyzer').absolute.path),
      ];

      test('should analyze files', () async {
        final config = _createConfig(analyzerExcludePatterns: analyzerExcludes);

        final result = await analyzer.runCliAnalysis(
          folders,
          rootDirectory,
          config,
        );

        final report = result.single.relativePath;

        expect(report, endsWith('unused_file.dart'));
      });

      test('should resolve package imports across monorepo contexts', () async {
        final fixturePath = normalize(
            File('test/resources/unused_files_monorepo_analyzer')
                .absolute
                .path);
        final packageConfig =
            File(join(fixturePath, '.dart_tool', 'package_config.json'));
        await packageConfig.parent.create(recursive: true);

        try {
          await packageConfig.writeAsString('''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "package_a",
      "rootUri": "../package_a",
      "packageUri": "lib/",
      "languageVersion": "3.5"
    },
    {
      "name": "package_b",
      "rootUri": "../package_b",
      "packageUri": "lib/",
      "languageVersion": "3.5"
    }
  ]
}
''');

          final result = await analyzer.runCliAnalysis(
            [
              join(fixturePath, 'package_a/lib'),
              join(fixturePath, 'package_b/lib'),
            ],
            rootDirectory,
            _createConfig(isMonorepo: true),
          );
          final reportedPaths = result
              .map((report) => relative(report.path, from: fixturePath))
              .toSet();

          expect(
            reportedPaths,
            containsAll([
              'package_a/lib/unused_a.dart',
              'package_b/lib/unused_barrel.dart',
              'package_b/lib/unused_entrypoint.dart',
            ]),
          );
          expect(
              reportedPaths, isNot(contains('package_b/lib/package_b.dart')));
          expect(
            reportedPaths,
            isNot(contains('package_b/lib/src/used_child.dart')),
          );

          final noMonorepoResult = await analyzer.runCliAnalysis(
            [
              join(fixturePath, 'package_a/lib'),
              join(fixturePath, 'package_b/lib'),
            ],
            rootDirectory,
            _createConfig(),
          );
          final noMonorepoPaths = noMonorepoResult
              .map((report) => relative(report.path, from: fixturePath))
              .toSet();

          expect(
            noMonorepoPaths,
            unorderedEquals([
              'package_a/lib/unused_a.dart',
              'package_b/lib/unused_entrypoint.dart',
            ]),
          );
        } finally {
          await packageConfig.parent.delete(recursive: true);
        }
      });

      test('should return a reporter', () {
        final reporter = analyzer.getReporter(name: 'console', output: stdout);

        expect(reporter, isA<UnusedFilesConsoleReporter>());
      });
    },
    testOn: 'posix',
  );

  test(
    'should count files matched by --exclude as importers, but not report them',
    () async {
      final root = createGeneratedUsagesProject();

      final result = await const UnusedFilesAnalyzer().runCliAnalysis(
        ['lib'],
        root,
        _createConfig(excludePatterns: defaultExcludes),
      );

      expect(
        result.map((report) => report.relativePath),
        unorderedEquals(['lib/unused.dart']),
      );
    },
    testOn: 'posix',
  );
}

UnusedFilesConfig _createConfig({
  Iterable<String> excludePatterns = const [],
  Iterable<String> analyzerExcludePatterns = const [],
  bool isMonorepo = false,
}) =>
    UnusedFilesConfig(
      excludePatterns: excludePatterns,
      analyzerExcludePatterns: analyzerExcludePatterns,
      isMonorepo: isMonorepo,
      shouldPrintConfig: false,
    );
