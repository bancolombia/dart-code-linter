import 'super_constructor.dart';

class SubOfSuperBase extends SuperBase {
  SubOfSuperBase() : super.namedForSuper();
}

void main() {
  SubOfSuperBase();
}
