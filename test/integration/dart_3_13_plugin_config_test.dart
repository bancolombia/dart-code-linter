import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final dart = Platform.environment['DART_3_13'];
  final skip =
      dart == null ? 'Set DART_3_13 to a Dart 3.13 executable.' : false;

  test('Dart 3.13 supports split plugin and DCL rule configuration', () async {
    final project = Directory.systemTemp.createTempSync('dcl-dart-3-13-');
    addTearDown(() => project.deleteSync(recursive: true));

    final packageRoot = p.normalize(Directory.current.absolute.path);
    File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: dcl_dart_3_13_fixture
environment:
  sdk: ^3.13.0
dev_dependencies:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
''');
    Directory(p.join(project.path, 'lib')).createSync();
    File(p.join(project.path, 'lib', 'main.dart')).writeAsStringSync('''
void check(dynamic value) {
  if (value == 42) print(7);
}
''');

    final pubGet = await Process.run(dart!, ['pub', 'get'],
        workingDirectory: project.path);
    expect(pubGet.exitCode, 0, reason: '${pubGet.stdout}\n${pubGet.stderr}');

    final structured = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      no-magic-number:
        severity: warning
        allowed: [42]
''');
    expect(structured.output, contains('invalid_section_format'));

    final enabled = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      avoid-dynamic: true
''');
    expect(enabled.output, contains('avoid-dynamic'));

    final disabled = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      avoid-dynamic: false
''');
    expect(disabled.output, isNot(contains('avoid-dynamic')));

    final configured = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      no-magic-number: warning

dart_code_linter:
  rules:
    - no-magic-number:
        severity: error
        allowed: [42, 7]
''');
    expect(configured.output, isNot(contains('no-magic-number')));

    final severity = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      no-magic-number: error

dart_code_linter:
  rules:
    - no-magic-number:
        severity: warning
        allowed: [42]
''');
    expect(
      severity.output,
      contains(RegExp('error.+no-magic-number')),
    );

    final missingRequiredConfig = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      ban-name: true
''');
    expect(
      missingRequiredConfig.output,
      contains("'ban-name' requires configuration"),
    );

    final requiredConfig = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      ban-name: warning

dart_code_linter:
  rules:
    - ban-name:
        entries:
          - ident: value
            description: Use a domain-specific name.
''');
    expect(requiredConfig.output, contains('ban-name'));

    final rulesExcluded = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      avoid-dynamic: warning

dart_code_linter:
  rules-exclude:
    - lib/**
  rules:
    avoid-dynamic: true
''');
    expect(rulesExcluded.output, isNot(contains('avoid-dynamic')));

    final missingRequiredConfigExcluded = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      ban-name: true

dart_code_linter:
  rules-exclude:
    - lib/**
''');
    expect(
      missingRequiredConfigExcluded.output,
      isNot(contains('ban-name')),
    );

    final invalid = await _analyze(dart, project, '''
plugins:
  dart_code_linter:
    path: ${_yamlString(packageRoot)}
    diagnostics:
      no-magic-number: true

dart_code_linter:
  rules: no-magic-number
''');
    expect(
      invalid.output,
      contains("Expected 'dart_code_linter.rules' to be a list or map"),
    );
    expect(invalid.output, isNot(contains('unexpected error')));
    expect(invalid.output, contains('no-magic-number'));
  }, skip: skip, timeout: const Timeout(Duration(minutes: 5)));
}

Future<({String output})> _analyze(
  String dart,
  Directory project,
  String options,
) async {
  File(p.join(project.path, 'analysis_options.yaml'))
      .writeAsStringSync(options);
  final result = await Process.run(
    dart,
    ['analyze'],
    workingDirectory: project.path,
  );
  return (output: '${result.stdout}\n${result.stderr}');
}

String _yamlString(String value) => "'${value.replaceAll("'", "''")}'";
