/// Represents a single change.
class Replacement {
  /// The human-readable description of the change to be applied.
  final String comment;

  /// The code with changes to replace original code with.
  final String replacement;

  /// The priority of the change.
  final int priority;

  /// Initialize a newly created [Replacement] with the given [comment] and [replacement].
  const Replacement({
    required this.comment,
    required this.replacement,
    this.priority = 1,
  });
}
