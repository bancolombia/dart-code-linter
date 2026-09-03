// Importable by any consumer as `package:.../public_api.dart` without any
// other file exporting it, so nothing here can be suggested for privatizing:
// not the top level declarations, and not the public members of their types,
// which a consumer holding `SurfaceType` reaches just as directly. `lib/src`
// is the other side of this, and `--monorepo` lifts it.

class SurfaceType {
  int usedOnlyHere() => 1;

  int caller() => usedOnlyHere();
}

int surfaceFunction() => SurfaceType().caller();
