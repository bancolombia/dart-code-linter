// Regression fixture: a member usage recorded through the conditional import
// bookkeeping in `_isUnused` must not mask an unrelated top level declaration
// of the same name and `ElementKind`, mirroring the same-library fix that
// `_isEqualElements` already has (see `masked_top_level.dart`). The
// conditional import branch has its own, separate name-and-kind fallback that
// the same fix never reached.

/// Never referenced anywhere: must be reported even though
/// `Resettable.value` is used below and shares its name and `ElementKind`
/// (both are getters).
int get value => 0;

class Resettable {
  int get value => 1;
}
