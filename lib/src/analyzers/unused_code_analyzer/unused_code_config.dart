import '../../config_builder/models/analysis_options.dart';

/// Represents raw unused code config which can be merged with other raw configs.
///
/// Bool flags are `bool?` so an override can explicitly disable what the
/// base config enabled.
class UnusedCodeConfig {
  final Iterable<String> excludePatterns;
  final Iterable<String> analyzerExcludePatterns;
  final bool? isMonorepo;
  final bool? shouldPrintConfig;

  /// Whether unused private members in type declarations (methods, fields,
  /// getters, setters and named constructors) should be reported in addition
  /// to top-level declarations.
  final bool? analyzePrivateMembers;

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
        isMonorepo: null,
        shouldPrintConfig: null,
        analyzePrivateMembers: options.readBoolOrNull(
          ['unused-code', 'analyze-private-members'],
          packageRelated: true,
        ),
      );

  /// Creates the config from cli args. Pass `null` for an unparsed flag.
  factory UnusedCodeConfig.fromArgs(
    Iterable<String> excludePatterns, {
    required bool? isMonorepo,
    required bool? shouldPrintConfig,
    required bool? analyzePrivateMembers,
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
        isMonorepo: overrides.isMonorepo ?? isMonorepo,
        shouldPrintConfig: overrides.shouldPrintConfig ?? shouldPrintConfig,
        analyzePrivateMembers:
            overrides.analyzePrivateMembers ?? analyzePrivateMembers,
      );
}
