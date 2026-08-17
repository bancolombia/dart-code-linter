import 'package:meta/meta.dart';

// Annotations that say a member is reached from somewhere this analysis cannot
// see, or from a subtype rather than through a reference.

class AnnotatedMembers {
  @protected
  void protectedMember() {}

  @visibleForTesting
  void testOnlyMember() {}

  @visibleForOverriding
  void overridableMember() {}

  @mustBeOverridden
  void mustBeOverriddenMember() {}

  @pragma('vm:entry-point')
  void nativeEntryPoint() {}

  // Called by `json.encode` rather than through a reference.
  Map<String, Object> toJson() => {};

  void plainUnused() {}
}

void main() {
  AnnotatedMembers();
}
