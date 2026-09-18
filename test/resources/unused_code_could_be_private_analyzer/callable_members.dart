// A `call` method is reached by implicit invocation, `obj(...)`, which binds
// only a member literally named `call`. Renaming it does not compile, in any
// library, so it belongs with the operators rather than with the members whose
// callers merely cannot be seen.
//
// Only a *method* makes an object callable: verified with `dart analyze` that
// `obj(...)` is `invocation_of_non_function_expression` when `call` is a field
// or a getter, and a static `call` is only ever reached by an explicit
// `Type.call(...)`. Those three are renameable and stay suggested, which is
// what keeps the exemption from swallowing every member named `call`.

class Callable {
  int call(int x) => x + 1;

  int viaImplicitInvocation() => this(1);
}

class NotCallableField {
  NotCallableField(this.call);

  final int Function(int) call;

  int viaExplicitInvocation() => call(1);
}

class NotCallableGetter {
  int Function(int) get call => (x) => x + 1;

  int viaExplicitInvocation() => call(1);
}

class NotCallableStatic {
  static int call(int x) => x + 1;

  int viaTypeName() => NotCallableStatic.call(1);
}

void main() {
  Callable().viaImplicitInvocation();
  NotCallableField((x) => x).viaExplicitInvocation();
  NotCallableGetter().viaExplicitInvocation();
  NotCallableStatic().viaTypeName();
}
