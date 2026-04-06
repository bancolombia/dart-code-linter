import 'dart:io';

import 'package:dart_code_linter/src/version.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('packageVersion matches pubspec.yaml version', () {
    final pubspecFile = File('pubspec.yaml');
    final pubspec = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final pubspecVersion = pubspec['version'] as String;

    expect(
      packageVersion,
      equals(pubspecVersion),
      reason:
          'lib/src/version.dart packageVersion must be updated when pubspec.yaml version changes',
    );
  });
}
