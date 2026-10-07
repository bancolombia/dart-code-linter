// The suggestions inherit every exemption the public members check applies:
// an analysis that cannot see how a member is reached cannot tell that
// everything reaching it sits in one library either.

import 'package:meta/meta.dart';

class Annotated {
  @protected
  int protectedMember() => 1;

  @visibleForTesting
  int testOnlyMember() => 2;

  @visibleForOverriding
  int overridableMember() => 3;

  @mustBeOverridden
  int mustBeOverriddenMember() => 4;

  @pragma('vm:entry-point')
  int nativeEntryPoint() => 5;

  // Called by `json.encode` by convention rather than by reference.
  Map<String, Object?> toJson() => const {};

  // Reached by dispatch on `Object` rather than by a reference here.
  @override
  String toString() => 'Annotated';

  int plainMember() => 6;

  int useEverything() =>
      protectedMember() +
      testOnlyMember() +
      overridableMember() +
      mustBeOverriddenMember() +
      nativeEntryPoint() +
      plainMember() +
      toJson().length +
      toString().length;
}

@visibleForTesting
int testOnlyTopLevel() => 7;

@pragma('vm:entry-point')
int nativeTopLevel() => 8;

int useTopLevels() => testOnlyTopLevel() + nativeTopLevel();

void main() {
  Annotated().useEverything();
  useTopLevels();
}
