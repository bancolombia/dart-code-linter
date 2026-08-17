import 'dart:core' as core;

class Bridge {
  @core.pragma('vm:entry-point')
  void calledFromNative() {}

  void deadControl() {}
}

void main() {
  Bridge();
}
