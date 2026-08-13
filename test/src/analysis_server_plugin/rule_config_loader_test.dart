import 'dart:io';

import 'package:dart_code_linter/src/analysis_server_plugin/rule_config_loader.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/models/severity.dart';
import 'package:test/test.dart';

void main() {
  late Directory project;

  setUp(() => project = Directory.systemTemp.createTempSync('dcl-config-'));
  tearDown(() => project.deleteSync(recursive: true));

  test('loads configured severity and parameters', () {
    _writeOptions(project, '''
dart_code_linter:
  rules:
    - no-magic-number:
        severity: error
        allowed: [42]
''');

    final rule = loadAnalysisServerRule(project.path, 'no-magic-number').rule;

    expect(rule?.severity, Severity.error);
    expect(rule?.toJson()['allowed'], [42]);
  });

  test('loads boolean enabled and disabled rules', () {
    _writeOptions(project, '''
dart_code_linter:
  rules:
    no-magic-number: true
    avoid-dynamic: false
''');

    expect(loadAnalysisServerRule(project.path, 'no-magic-number').rule,
        isNotNull);
    expect(loadAnalysisServerRule(project.path, 'avoid-dynamic').rule, isNull);
  });

  test('returns null when rule has no independent configuration', () {
    _writeOptions(project, '''
dart_code_linter:
  rules:
    - avoid-dynamic
''');

    expect(
        loadAnalysisServerRule(project.path, 'no-magic-number').rule, isNull);
  });

  test('rejects malformed rule configuration with source path', () {
    final file = _writeOptions(project, '''
dart_code_linter:
  rules: no-magic-number
''');

    expect(
      () => loadAnalysisServerRule(project.path, 'no-magic-number').rule,
      throwsA(
        isA<FormatException>()
            .having((error) => error.message, 'message', contains('rules'))
            .having((error) => error.source, 'source', file.path),
      ),
    );
  });

  test('rejects malformed entries elsewhere in rule list', () {
    _writeOptions(project, '''
dart_code_linter:
  rules:
    - avoid-dynamic
    - no-magic-number: true
      avoid-late-keyword: true
''');

    expect(
      () => loadAnalysisServerRule(project.path, 'avoid-dynamic').rule,
      throwsA(isA<FormatException>()),
    );
  });

  test('loads inherited DCL configuration', () {
    File('${project.path}/base.yaml').writeAsStringSync('''
dart_code_linter:
  rules:
    - no-magic-number:
        severity: error
        allowed: [42]
''');
    _writeOptions(project, 'include: base.yaml\n');

    final rule = loadAnalysisServerRule(project.path, 'no-magic-number').rule;

    expect(rule?.severity, Severity.error);
    expect(rule?.toJson()['allowed'], [42]);
  });

  test('loads active ancestor analysis options', () {
    final workspace = Directory.systemTemp.createTempSync('dcl-workspace-');
    addTearDown(() => workspace.deleteSync(recursive: true));

    final package = Directory('${workspace.path}/package')..createSync();
    _writePubspec(package);
    File('${workspace.path}/analysis_options.yaml').writeAsStringSync('''
dart_code_linter:
  rules:
    - no-magic-number:
        severity: error
        allowed: [42]
''');

    final rule = loadAnalysisServerRule(package.path, 'no-magic-number').rule;

    expect(rule?.severity, Severity.error);
    expect(rule?.toJson()['allowed'], [42]);
  });

  test('loads inherited DCL configuration from extends', () {
    File('${project.path}/dcl_base.yaml').writeAsStringSync('''
dart_code_linter:
  rules:
    - no-magic-number:
        severity: error
        allowed: [42]
''');
    _writeOptions(project, '''
dart_code_linter:
  extends:
    - dcl_base.yaml
''');

    final rule = loadAnalysisServerRule(project.path, 'no-magic-number').rule;

    expect(rule?.severity, Severity.error);
    expect(rule?.toJson()['allowed'], [42]);
  });

  test('rejects malformed inherited DCL configuration', () {
    File('${project.path}/base.yaml').writeAsStringSync('''
dart_code_linter:
  rules: no-magic-number
''');
    _writeOptions(project, 'include: base.yaml\n');

    expect(
      () => loadAnalysisServerRule(project.path, 'no-magic-number'),
      throwsA(isA<FormatException>()),
    );
  });

  test('repeated loads see changed configuration', () {
    _writeOptions(project, '''
dart_code_linter:
  rules:
    no-magic-number: false
''');
    expect(
      loadAnalysisServerRule(project.path, 'no-magic-number').rule,
      isNull,
    );

    _writeOptions(project, '''
dart_code_linter:
  rules:
    no-magic-number: true
''');
    expect(
      loadAnalysisServerRule(project.path, 'no-magic-number').rule,
      isNotNull,
    );
  });

  test('loads global rules-exclude patterns', () {
    _writeOptions(project, '''
dart_code_linter:
  rules-exclude:
    - test/**
  rules:
    no-magic-number: true
''');

    expect(
      loadAnalysisServerRule(project.path, 'no-magic-number').rulesExcludes,
      ['test/**'],
    );
  });

  test('rejects invalid severity instead of silently using none', () {
    _writeOptions(project, '''
dart_code_linter:
  rules:
    - no-magic-number:
        severity: fatal
''');

    expect(
      () => loadAnalysisServerRule(project.path, 'no-magic-number').rule,
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains("Invalid severity 'fatal' for 'no-magic-number'"),
        ),
      ),
    );
  });

  test('accepts mixed-case severity like CLI config', () {
    _writeOptions(project, '''
dart_code_linter:
  rules:
    - no-magic-number:
        severity: Warning
''');

    expect(
      loadAnalysisServerRule(project.path, 'no-magic-number').rule?.severity,
      Severity.warning,
    );
  });
}

File _writeOptions(Directory project, String contents) {
  _writePubspec(project);
  return File('${project.path}/analysis_options.yaml')
    ..writeAsStringSync(contents);
}

void _writePubspec(Directory project) {
  File('${project.path}/pubspec.yaml').writeAsStringSync('''
name: dcl_config_fixture
environment:
  sdk: ^3.5.0
''');
}
