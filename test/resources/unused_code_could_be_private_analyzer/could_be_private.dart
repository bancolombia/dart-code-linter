// The baseline: a class whose members are split between references that stay
// inside this library and references that come from `consumer.dart`. Only the
// former can be made private.

class Api {
  int localField = 1;

  int foreignField = 2;

  int get localGetter => localField;

  int get foreignGetter => foreignField;

  set localSetter(int value) => localField = value;

  set foreignSetter(int value) => foreignField = value;

  int localMethod() => localGetter;

  int foreignMethod() => foreignGetter;

  static int localStatic() => 3;

  static int foreignStatic() => 4;

  Api();

  Api.localNamed();

  Api.foreignNamed();

  // Already private, so there is nothing to suggest.
  int _privateMethod() => 5;

  int usesThePrivateOne() => _privateMethod();
}

// A second class in the same library: a reference from here is still local,
// since privacy in Dart is scoped to the library rather than to the class.
// Nothing outside this library names `ApiCaller` itself either, so the class
// is a top level suggestion of its own.
class ApiCaller {
  int run() {
    final api = Api.localNamed()
      ..localSetter = 1
      ..localMethod();

    return api.usesThePrivateOne() + Api.localStatic();
  }
}

void main() {
  ApiCaller().run();
}
