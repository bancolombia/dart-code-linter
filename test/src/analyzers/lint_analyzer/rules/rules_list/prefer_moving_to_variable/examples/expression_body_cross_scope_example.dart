class SomeService {
  String display = 'value';
}

class MyWidget {
  final SomeService service;

  MyWidget(this.service);

  // same call in two separate expression bodies — each body is its own scope,
  // the fix should be a field, not a local variable, so no lint expected
  String get title => service.display;

  String get subtitle => service.display;
}
