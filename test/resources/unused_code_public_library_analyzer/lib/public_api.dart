// Importable by any consumer as `package:.../public_api.dart` without any
// other file exporting it, so nothing declared at the top level here can be
// made private. The members of its types are not on that surface and are
// still analyzed.

class SurfaceType {
  int usedOnlyHere() => 1;

  int caller() => usedOnlyHere();
}

int surfaceFunction() => SurfaceType().caller();
