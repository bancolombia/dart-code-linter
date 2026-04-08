class SomeService {
  String display = 'value';
}

// lambda assigned to a variable — duplicates within the lambda body
final processService =
    (SomeService s) => s.display.trim() + s.display.trim(); // LINT LINT
