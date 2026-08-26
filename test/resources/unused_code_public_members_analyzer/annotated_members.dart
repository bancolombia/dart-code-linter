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

// A type level `@pragma('vm:entry-point')` means only that the class may be
// allocated directly from native or VM code. It does NOT retain members: each
// one needs its own pragma. So a member without one is still dead code and has
// to be reported, which is the opposite of how `@JSExport` behaves on a class.
// See
// https://github.com/dart-lang/sdk/blob/master/runtime/docs/compiler/aot/entry_point_pragma.md
@pragma('vm:entry-point')
class NativeAllocated {
  @pragma('vm:entry-point')
  void calledFromNative() {}

  void notAnEntryPoint() {}
}

void main() {
  AnnotatedMembers();
  NativeAllocated();
}
