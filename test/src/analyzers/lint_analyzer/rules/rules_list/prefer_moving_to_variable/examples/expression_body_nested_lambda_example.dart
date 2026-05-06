class SomeService {
  String display = 'value';
}

String transform(String Function() fn) => fn();

class MyWidget {
  final SomeService service;

  MyWidget(this.service);

  // service.display.trim() in the outer expression body AND inside a nested
  // lambda — different scopes, no lint expected
  String get info =>
      service.display.trim() + transform(() => service.display.trim());
}
