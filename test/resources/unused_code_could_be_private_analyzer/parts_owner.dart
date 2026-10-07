// A `part` shares the library of its owner, so a reference from there is
// local: privacy in Dart is scoped to the library, not to the file.

part 'parts_part.dart';

class PartOwner {
  int usedFromThePart() => 1;
}

void main() {
  usePartOwner();
}
