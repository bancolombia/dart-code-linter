// A `super.named()` call in another library is a reference like any other, and
// has to keep the constructor it names public.

class SuperBase {
  SuperBase.namedForSuper();

  SuperBase.onlyLocal();

  static SuperBase makeLocal() => SuperBase.onlyLocal();
}

void main() {
  SuperBase.makeLocal();
}
