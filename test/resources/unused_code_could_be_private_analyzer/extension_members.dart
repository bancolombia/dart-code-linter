// An extension has no subtypes, so only the references matter.

extension LocalExtension on int {
  int get doubled => this * 2;
}

int useTheExtension() => 2.doubled;

void main() {
  useTheExtension();
}
