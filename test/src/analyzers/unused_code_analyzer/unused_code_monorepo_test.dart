import 'dart:io';

import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/models/unused_code_file_report.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/unused_code_analyzer.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/unused_code_config.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  const analyzer = UnusedCodeAnalyzer();
  final fixtureRoot = normalize(
    File('test/resources/unused_code_monorepo_analyzer').absolute.path,
  );
  final folders = [
    normalize(join(fixtureRoot, 'package_a', 'lib')),
    normalize(join(fixtureRoot, 'package_b', 'lib')),
  ];

  setUp(() {
    _writePackageConfig(
      join(fixtureRoot, 'package_a'),
      packageARootUri: '..',
      packageBRootUri: '../../package_b',
    );
    _writePackageConfig(
      join(fixtureRoot, 'package_b'),
      packageARootUri: '../../package_a',
      packageBRootUri: '..',
    );
  });

  tearDown(() {
    Directory(join(fixtureRoot, 'package_a', '.dart_tool'))
        .deleteSync(recursive: true);
    Directory(join(fixtureRoot, 'package_b', '.dart_tool'))
        .deleteSync(recursive: true);
  });

  test('tracks package references across monorepo analysis contexts', () async {
    final monorepoResult = await analyzer.runCliAnalysis(
      folders,
      '',
      _createConfig(isMonorepo: true),
    );
    final monorepoNames = _names(monorepoResult);

    expect(monorepoNames, contains('UnusedApi'));
    expect(monorepoNames, isNot(contains('SharedApi')));

    final packageResult = await analyzer.runCliAnalysis(
      folders,
      '',
      _createConfig(isMonorepo: false),
    );
    final packageNames = _names(packageResult);

    expect(packageNames, isNot(contains('SharedApi')));
    expect(packageNames, isNot(contains('UnusedApi')));
  });

  test('counts a prefixed reference inside a single package', () async {
    // The package boundary is not what this is about: the same reference
    // without `as api` is already counted. What was missed is the prefix.
    final names = _names(await analyzer.runCliAnalysis(
      folders,
      '',
      _createConfig(isMonorepo: true),
    ));

    expect(names, isNot(contains('InternalApi')));
  });

  test('counts prefixed references from a library and its part file', () async {
    // A library and its part share one `PrefixElement` but are analyzed as
    // separate files, so both have to survive being merged into one usage.
    final names = _names(await analyzer.runCliAnalysis(
      folders,
      '',
      _createConfig(isMonorepo: true),
    ));

    expect(names, isNot(contains('LibraryPrefixed')));
    expect(names, isNot(contains('PartPrefixed')));
  });
}

Iterable<String> _names(Iterable<UnusedCodeFileReport> reports) => reports
    .expand((report) => report.issues.map((issue) => issue.declarationName));

void _writePackageConfig(
  String packageRoot, {
  required String packageARootUri,
  required String packageBRootUri,
}) {
  final packageConfig =
      File(join(packageRoot, '.dart_tool', 'package_config.json'));
  packageConfig.parent.createSync(recursive: true);
  packageConfig.writeAsStringSync('''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "package_a",
      "rootUri": "$packageARootUri",
      "packageUri": "lib/",
      "languageVersion": "3.5"
    },
    {
      "name": "package_b",
      "rootUri": "$packageBRootUri",
      "packageUri": "lib/",
      "languageVersion": "3.5"
    }
  ]
}
''');
}

UnusedCodeConfig _createConfig({required bool isMonorepo}) => UnusedCodeConfig(
      excludePatterns: const [],
      analyzerExcludePatterns: const [],
      isMonorepo: isMonorepo,
      shouldPrintConfig: false,
      analyzePrivateMembers: false,
      analyzePublicMembers: false,
      suggestPrivateMembers: false,
    );
