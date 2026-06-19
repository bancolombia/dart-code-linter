import '../../config_builder/models/analysis_options.dart';

/// Represents raw unused code config which can be merged with other raw configs.
class UnusedCodeConfig {
  final Iterable<String> excludePatterns;
  final Iterable<String> analyzerExcludePatterns;
  final bool isMonorepo;
  final bool shouldPrintConfig;

  /// Whether unused private class members (methods, fields, getters and
  /// setters) should be reported in addition to top-level declarations.
  final bool analyzePrivateMembers;

  const UnusedCodeConfig({
    required this.excludePatterns,
    required this.analyzerExcludePatterns,
    required this.isMonorepo,
    required this.shouldPrintConfig,
    required this.analyzePrivateMembers,
  });

  /// Creates the config from analysis [options].
  factory UnusedCodeConfig.fromAnalysisOptions(AnalysisOptions options) =>
      UnusedCodeConfig(
        excludePatterns: const [],
        analyzerExcludePatterns:
            options.readIterableOfString(['analyzer', 'exclude']),
        isMonorepo: false,
        shouldPrintConfig: false,
        analyzePrivateMembers: options.readBool(
          ['unused-code', 'analyze-private-members'],
          packageRelated: true,
        ),
      );

  /// Creates the config from cli args.
  factory UnusedCodeConfig.fromArgs(
    Iterable<String> excludePatterns, {
    required bool isMonorepo,
    required bool shouldPrintConfig,
    required bool analyzePrivateMembers,
  }) =>
      UnusedCodeConfig(
        shouldPrintConfig: shouldPrintConfig,
        excludePatterns: excludePatterns,
        analyzerExcludePatterns: const [],
        isMonorepo: isMonorepo,
        analyzePrivateMembers: analyzePrivateMembers,
      );

  /// Merges two configs into a single one.
  ///
  /// Config coming from [overrides] has a higher priority
  /// and overrides conflicting entries.
  UnusedCodeConfig merge(UnusedCodeConfig overrides) => UnusedCodeConfig(
        excludePatterns: {...excludePatterns, ...overrides.excludePatterns},
        analyzerExcludePatterns: {
          ...analyzerExcludePatterns,
          ...overrides.analyzerExcludePatterns,
        },
        isMonorepo: isMonorepo || overrides.isMonorepo,
        shouldPrintConfig: shouldPrintConfig || overrides.shouldPrintConfig,
        analyzePrivateMembers:
            analyzePrivateMembers || overrides.analyzePrivateMembers,
      );
}
