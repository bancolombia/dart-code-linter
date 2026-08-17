import 'package:glob/glob.dart';

/// Represents converted unused code config which contains parsed entities.
class UnusedCodeAnalysisConfig {
  final Iterable<Glob> globalExcludes;
  final Iterable<Glob> analyzerExcludedPatterns;
  final bool isMonorepo;
  final bool analyzePrivateMembers;
  final bool analyzePublicMembers;

  /// Whether members of type declarations take part in the analysis at all,
  /// either as candidates or as recorded usages.
  bool get analyzeMembers => analyzePrivateMembers || analyzePublicMembers;

  const UnusedCodeAnalysisConfig(
    this.globalExcludes,
    this.analyzerExcludedPatterns, {
    required this.isMonorepo,
    required this.analyzePrivateMembers,
    required this.analyzePublicMembers,
  });

  Map<String, Object?> toJson() => {
        'global-excludes': globalExcludes.map((glob) => glob.pattern).toList(),
        'analyzer-excluded-patterns':
            analyzerExcludedPatterns.map((glob) => glob.pattern).toList(),
        'is-monorepo': isMonorepo,
        'analyze-private-members': analyzePrivateMembers,
        'analyze-public-members': analyzePublicMembers,
      };
}
