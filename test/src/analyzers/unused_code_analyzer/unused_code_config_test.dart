import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/unused_code_config.dart';
import 'package:dart_code_linter/src/config_builder/models/analysis_options.dart';
import 'package:test/test.dart';

const _options = AnalysisOptions('path', {
  'analyzer': {
    'exclude': ['test/resources/**'],
    'plugins': ['dart_code_linter'],
    'strong-mode': {'implicit-casts': false, 'implicit-dynamic': false},
  },
});

const _defaults = UnusedCodeConfig(
  excludePatterns: ['test/resources/**'],
  analyzerExcludePatterns: ['test/**'],
  isMonorepo: false,
  shouldPrintConfig: false,
  analyzePrivateMembers: false,
  analyzePublicMembers: false,
);

const _empty = UnusedCodeConfig(
  excludePatterns: [],
  analyzerExcludePatterns: [],
  isMonorepo: false,
  shouldPrintConfig: false,
  analyzePrivateMembers: false,
  analyzePublicMembers: false,
);

const _merged = UnusedCodeConfig(
  excludePatterns: ['test/resources/**'],
  analyzerExcludePatterns: ['test/**', 'examples/**'],
  isMonorepo: true,
  shouldPrintConfig: true,
  analyzePrivateMembers: true,
  analyzePublicMembers: true,
);

const _overrides = UnusedCodeConfig(
  excludePatterns: [],
  analyzerExcludePatterns: ['examples/**'],
  isMonorepo: true,
  shouldPrintConfig: true,
  analyzePrivateMembers: true,
  analyzePublicMembers: true,
);

void main() {
  group('UnusedCodeConfig', () {
    group('fromAnalysisOptions constructs instance from passed', () {
      test('empty options', () {
        final config = UnusedCodeConfig.fromAnalysisOptions(
          const AnalysisOptions(null, {}),
        );

        expect(config.excludePatterns, isEmpty);
        expect(config.analyzerExcludePatterns, isEmpty);
        expect(config.isMonorepo, null);
        expect(config.shouldPrintConfig, null);
        expect(config.analyzePrivateMembers, null);
        expect(config.analyzePublicMembers, null);
      });

      test('data', () {
        final config = UnusedCodeConfig.fromAnalysisOptions(_options);

        expect(config.analyzerExcludePatterns, equals(['test/resources/**']));
      });

      test('analyze-private-members option', () {
        final config = UnusedCodeConfig.fromAnalysisOptions(
          const AnalysisOptions('path', {
            'dart_code_linter': {
              'unused-code': {'analyze-private-members': true},
            },
          }),
        );

        expect(config.analyzePrivateMembers, true);
        expect(config.analyzePublicMembers, null);
      });

      test('analyze-public-members option', () {
        final config = UnusedCodeConfig.fromAnalysisOptions(
          const AnalysisOptions('path', {
            'dart_code_linter': {
              'unused-code': {'analyze-public-members': true},
            },
          }),
        );

        expect(config.analyzePublicMembers, true);
        expect(config.analyzePrivateMembers, null);
      });
    });

    group('fromArgs constructs instance from passed', () {
      test('data', () {
        final config = UnusedCodeConfig.fromArgs(
          ['hello'],
          isMonorepo: true,
          shouldPrintConfig: true,
          analyzePrivateMembers: true,
          analyzePublicMembers: true,
        );

        expect(config.excludePatterns, equals(['hello']));
        expect(config.analyzerExcludePatterns, isEmpty);
        expect(config.isMonorepo, true);
        expect(config.shouldPrintConfig, true);
        expect(config.analyzePrivateMembers, true);
        expect(config.analyzePublicMembers, true);
      });
    });

    group('merge constructs instance with data from', () {
      test('defaults and empty configs', () {
        final result = _defaults.merge(_empty);

        expect(result.excludePatterns, equals(_defaults.excludePatterns));
        expect(
          result.analyzerExcludePatterns,
          equals(_defaults.analyzerExcludePatterns),
        );
        expect(result.isMonorepo, equals(_defaults.isMonorepo));
        expect(result.shouldPrintConfig, equals(_defaults.shouldPrintConfig));
      });

      test('empty and overrides configs', () {
        final result = _empty.merge(_overrides);

        expect(result.excludePatterns, equals(_overrides.excludePatterns));
        expect(
          result.analyzerExcludePatterns,
          equals(_overrides.analyzerExcludePatterns),
        );
        expect(result.isMonorepo, equals(_overrides.isMonorepo));
        expect(result.shouldPrintConfig, equals(_overrides.shouldPrintConfig));
      });

      test('defaults and overrides configs', () {
        final result = _defaults.merge(_overrides);

        expect(result.excludePatterns, equals(_merged.excludePatterns));
        expect(
          result.analyzerExcludePatterns,
          equals(_merged.analyzerExcludePatterns),
        );
        expect(result.isMonorepo, equals(_merged.isMonorepo));
        expect(result.shouldPrintConfig, equals(_merged.shouldPrintConfig));
        expect(
          result.analyzePrivateMembers,
          equals(_merged.analyzePrivateMembers),
        );
        expect(
          result.analyzePublicMembers,
          equals(_merged.analyzePublicMembers),
        );
      });

      // Tri-state (bool?) precedence for isMonorepo, shouldPrintConfig,
      // analyzePrivateMembers and analyzePublicMembers: an explicit override
      // must be able to disable what the base config enabled, and an unset
      // override must not.
      const enabledBase = UnusedCodeConfig(
        excludePatterns: [],
        analyzerExcludePatterns: [],
        isMonorepo: true,
        shouldPrintConfig: true,
        analyzePrivateMembers: true,
        analyzePublicMembers: true,
      );

      test('explicit false override wins over an enabled base', () {
        const overrides = UnusedCodeConfig(
          excludePatterns: [],
          analyzerExcludePatterns: [],
          isMonorepo: false,
          shouldPrintConfig: false,
          analyzePrivateMembers: false,
          analyzePublicMembers: false,
        );

        final result = enabledBase.merge(overrides);

        expect(result.isMonorepo, false);
        expect(result.shouldPrintConfig, false);
        expect(result.analyzePrivateMembers, false);
        expect(result.analyzePublicMembers, false);
      });

      test('unset (null) override falls back to the base config', () {
        const overrides = UnusedCodeConfig(
          excludePatterns: [],
          analyzerExcludePatterns: [],
          isMonorepo: null,
          shouldPrintConfig: null,
          analyzePrivateMembers: null,
          analyzePublicMembers: null,
        );

        final result = enabledBase.merge(overrides);

        expect(result.isMonorepo, true);
        expect(result.shouldPrintConfig, true);
        expect(result.analyzePrivateMembers, true);
        expect(result.analyzePublicMembers, true);
      });
    });
  });
}
