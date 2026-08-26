import 'unconditional_impl.dart'
    if (dart.library.html) 'conditional_impl.dart'
    if (dart.library.io) 'conditional_impl.dart';

void main() {
  Wrapper(1) + Wrapper(2);
}
