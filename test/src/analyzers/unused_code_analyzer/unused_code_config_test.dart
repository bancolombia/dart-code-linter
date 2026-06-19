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
);

const _empty = UnusedCodeConfig(
  excludePatterns: [],
  analyzerExcludePatterns: [],
  isMonorepo: false,
  shouldPrintConfig: false,
  analyzePrivateMembers: false,
);

const _merged = UnusedCodeConfig(
  excludePatterns: ['test/resources/**'],
  analyzerExcludePatterns: ['test/**', 'examples/**'],
  isMonorepo: true,
  shouldPrintConfig: true,
  analyzePrivateMembers: true,
);

const _overrides = UnusedCodeConfig(
  excludePatterns: [],
  analyzerExcludePatterns: ['examples/**'],
  isMonorepo: true,
  shouldPrintConfig: true,
  analyzePrivateMembers: true,
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
        expect(config.isMonorepo, false);
        expect(config.shouldPrintConfig, false);
        expect(config.analyzePrivateMembers, false);
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
      });
    });

    group('fromArgs constructs instance from passed', () {
      test('data', () {
        final config = UnusedCodeConfig.fromArgs(
          ['hello'],
          isMonorepo: true,
          shouldPrintConfig: true,
          analyzePrivateMembers: true,
        );

        expect(config.excludePatterns, equals(['hello']));
        expect(config.analyzerExcludePatterns, isEmpty);
        expect(config.isMonorepo, true);
        expect(config.shouldPrintConfig, true);
        expect(config.analyzePrivateMembers, true);
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
      });
    });
  });
}
