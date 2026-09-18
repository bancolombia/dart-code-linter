import 'external_implementer.dart';

class Helper {
  int suppliedByASuperclass() => 4;
}

// The interesting shape: `suppliedByASuperclass` is not declared here, so a
// check that only looked at this class's own members would miss it.
class Implementer extends Helper implements Interface {
  @override
  int suppliedByTheImplementer() => 5;

  @override
  int useEverything() => 6;
}

void main() {
  Implementer().useEverything();
}
