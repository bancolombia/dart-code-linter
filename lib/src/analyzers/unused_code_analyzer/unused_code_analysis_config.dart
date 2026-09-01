import 'package:glob/glob.dart';

/// Represents converted unused code config which contains parsed entities.
class UnusedCodeAnalysisConfig {
  final Iterable<Glob> globalExcludes;
  final Iterable<Glob> analyzerExcludedPatterns;
  final bool isMonorepo;
  final bool analyzePrivateMembers;
  final bool analyzePublicMembers;
  final bool suggestPrivateMembers;

  /// Whether members of type declarations take part in the analysis at all,
  /// either as candidates or as recorded usages.
  ///
  /// [suggestPrivateMembers] counts: it reports members too, and needs the
  /// same member level usage recording to tell a local reference from a
  /// foreign one.
  bool get analyzeMembers =>
      analyzePrivateMembers || analyzePublicMembers || suggestPrivateMembers;

  const UnusedCodeAnalysisConfig(
    this.globalExcludes,
    this.analyzerExcludedPatterns, {
    required this.isMonorepo,
    required this.analyzePrivateMembers,
    required this.analyzePublicMembers,
    required this.suggestPrivateMembers,
  });

  Map<String, Object?> toJson() => {
        'global-excludes': globalExcludes.map((glob) => glob.pattern).toList(),
        'analyzer-excluded-patterns':
            analyzerExcludedPatterns.map((glob) => glob.pattern).toList(),
        'is-monorepo': isMonorepo,
        'analyze-private-members': analyzePrivateMembers,
        'analyze-public-members': analyzePublicMembers,
        'suggest-private-members': suggestPrivateMembers,
      };
}
