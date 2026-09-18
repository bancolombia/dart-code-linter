import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/unused_code_config.dart';
import 'package:dart_code_linter/src/config_builder/config_builder.dart';
import 'package:test/test.dart';

UnusedCodeConfig _config({
  bool? analyzePrivateMembers,
  bool? analyzePublicMembers,
  bool? suggestPrivateMembers,
}) =>
    UnusedCodeConfig(
      excludePatterns: const [],
      analyzerExcludePatterns: const [],
      isMonorepo: null,
      shouldPrintConfig: null,
      analyzePrivateMembers: analyzePrivateMembers,
      analyzePublicMembers: analyzePublicMembers,
      suggestPrivateMembers: suggestPrivateMembers,
    );

void main() {
  group('UnusedCodeAnalysisConfig', () {
    test('resolves unset member flags to disabled', () {
      final config = ConfigBuilder.getUnusedCodeConfig(_config(), '');

      expect(config.analyzePrivateMembers, false);
      expect(config.analyzePublicMembers, false);
      expect(config.suggestPrivateMembers, false);
      expect(config.analyzeMembers, false);
    });

    test('resolves set member flags', () {
      final config = ConfigBuilder.getUnusedCodeConfig(
        _config(analyzePrivateMembers: true, analyzePublicMembers: true),
        '',
      );

      expect(config.analyzePrivateMembers, true);
      expect(config.analyzePublicMembers, true);
      expect(config.analyzeMembers, true);
    });

    test('analyzeMembers is set by the suggestion flag alone', () {
      // The suggestions need member level usage recording just as much: the
      // whole verdict is about which library a member's references sit in.
      final config = ConfigBuilder.getUnusedCodeConfig(
        _config(suggestPrivateMembers: true),
        '',
      );

      expect(config.analyzeMembers, true);
      expect(config.analyzePrivateMembers, false);
      expect(config.analyzePublicMembers, false);
    });

    test('analyzeMembers is set by either flag alone', () {
      final withPrivate = ConfigBuilder.getUnusedCodeConfig(
        _config(analyzePrivateMembers: true),
        '',
      );
      final withPublic = ConfigBuilder.getUnusedCodeConfig(
        _config(analyzePublicMembers: true),
        '',
      );

      expect(withPrivate.analyzeMembers, true);
      expect(withPrivate.analyzePublicMembers, false);
      expect(withPublic.analyzeMembers, true);
      expect(withPublic.analyzePrivateMembers, false);
    });

    // The `--print-config` output, so both keys have to be there.
    test('reports both member flags in toJson', () {
      final config = ConfigBuilder.getUnusedCodeConfig(
        _config(analyzePublicMembers: true),
        '',
      );

      expect(
        config.toJson(),
        equals({
          'global-excludes': <String>[],
          'analyzer-excluded-patterns': <String>[],
          'is-monorepo': false,
          'analyze-private-members': false,
          'analyze-public-members': true,
          'suggest-private-members': false,
        }),
      );
    });
  });
}
