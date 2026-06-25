enum Color { red, green, blue }

String lookup() => 'red';

void main() {
  // convertible: simple arrow, name == literal
  Color.values.byName('red');

  // convertible: reversed operands
  Color.values.byName('green');

  // convertible: lookup is an arbitrary expression not referencing the param
  Color.values.byName(lookup());

  // NOT convertible: has an orElse argument
  Color.values.firstWhere((e) => e.name == 'blue', orElse: () => Color.red);

  // NOT convertible: closure compares a different property
  Color.values.firstWhere((e) => e.index == 0);

  // NOT convertible: block body, not a simple arrow
  Color.values.firstWhere((e) {
    return e.name == 'red';
  });

  // NOT convertible: lookup references the closure parameter
  Color.values.firstWhere((e) => e.name == e.toString());
}
