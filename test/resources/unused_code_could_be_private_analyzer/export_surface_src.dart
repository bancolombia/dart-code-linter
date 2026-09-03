// Re-exported through `export_surface_barrel.dart`, which puts `Exported` on
// the package's import surface: any consumer, seen or unseen, can name it, and
// can reach the public members of it just as directly. Nothing here is
// suggested, members included. The unused verdict is unaffected.

class Exported {
  int memberUsedLocally() => 1;

  int caller() => memberUsedLocally();
}

void main() {
  Exported().caller();
}
