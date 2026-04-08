class SomeService {
  String display = 'value';
}

class MyWidget {
  final SomeService service;

  MyWidget(this.service);

  // within one expression body — two duplicates
  String get info =>
      service.display.trim() + service.display.trim(); // LINT LINT

  // across two separate expression bodies — no lint
  String get title => service.display;

  String get subtitle => service.display;
}

// top-level expression-body function — two duplicates
String join(SomeService s) => s.display.trim() + s.display.trim(); // LINT LINT
