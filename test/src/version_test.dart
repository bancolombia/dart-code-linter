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

  test('analyzer plugin loader pins this exact package version', () {
    final loaderFile = File('tools/analyzer_plugin/pubspec.yaml');
    final loader = loadYaml(loaderFile.readAsStringSync()) as YamlMap;

    expect(
      loader['version'],
      equals(packageVersion),
      reason: 'tools/analyzer_plugin/pubspec.yaml version must track the '
          'package version',
    );

    // The analysis server copies this pubspec verbatim into
    // ~/.dartServer/.plugin_manager and resolves it against pub.dev. A range
    // therefore resolves to whatever published version satisfies it, which is
    // silently not the version this loader shipped in: DCL 4.2.0 and 4.2.1
    // both loaded 4.1.9 in the IDE while the CLI ran the installed version.
    // Pub cannot warn about that, because a satisfying version always exists,
    // so the exact pin is the only thing that rules the skew out.
    final constraint =
        (loader['dependencies'] as YamlMap)['dart_code_linter'] as Object?;
    expect(
      constraint,
      equals(packageVersion),
      reason: 'tools/analyzer_plugin/pubspec.yaml must pin dart_code_linter to '
          'exactly $packageVersion, not a range',
    );
  });
}
