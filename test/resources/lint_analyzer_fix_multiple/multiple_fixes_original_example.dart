// ignore_for_file: prefer_const_declarations, literal_only_boolean_expressions
class MultipleFixesExample {
  bool test({required bool a, required bool b, required bool c}) {
    final first = a == true;
    final second = b == true;
    final third = c == true;

    return first && second && third;
  }
}
