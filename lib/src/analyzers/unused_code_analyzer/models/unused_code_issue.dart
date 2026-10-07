import 'package:source_span/source_span.dart';

/// The kind of finding an [UnusedCodeIssue] carries.
enum UnusedCodeIssueKind {
  /// The declaration has no reference anywhere in the analyzed code.
  unused,

  /// The declaration is public and used, but every reference to it lives in
  /// the library that declares it, so it could be made private.
  couldBePrivate;

  /// The name of this kind in report output.
  String get id => switch (this) {
        UnusedCodeIssueKind.unused => 'unused',
        UnusedCodeIssueKind.couldBePrivate => 'could-be-private',
      };
}

/// Represents an issue detected by the unused code check.
class UnusedCodeIssue {
  /// The name of the unused declaration.
  final String declarationName;

  /// The type of the unused declaration.
  final String declarationType;

  /// What is being reported about the declaration.
  ///
  /// Defaults to [UnusedCodeIssueKind.unused], which is what the check
  /// reported before could be private suggestions existed.
  final UnusedCodeIssueKind kind;

  /// The source location associated with this issue.
  final SourceLocation location;

  /// Initialize a newly created [UnusedCodeIssue].
  ///
  /// The issue is associated with the given [location]. Used for
  /// creating an unused code report.
  const UnusedCodeIssue({
    required this.declarationName,
    required this.declarationType,
    required this.location,
    this.kind = UnusedCodeIssueKind.unused,
  });
}
