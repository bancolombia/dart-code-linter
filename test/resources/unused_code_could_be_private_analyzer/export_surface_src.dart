// Re-exported through `export_surface_barrel.dart`, which puts `Exported`
// itself on the package's import surface: any consumer, seen or unseen, can
// name it. Its members are not on that surface, so they keep being analyzed.

class Exported {
  int memberUsedLocally() => 1;

  int caller() => memberUsedLocally();
}

void main() {
  Exported().caller();
}
