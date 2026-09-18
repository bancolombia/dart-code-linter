// A field bound by a named `this.x` formal cannot be renamed: Dart forbids a
// named parameter starting with an underscore, so `this._x` does not compile
// in a named parameter position. A positional formal has no such rule.

class Config {
  Config({this.viaNamedFormal = 0});

  Config.positional(this.viaPositionalFormal);

  int viaNamedFormal = 0;

  int viaPositionalFormal = 0;

  int sum() => viaNamedFormal + viaPositionalFormal;
}

void main() {
  Config().sum();
  Config.positional(1).sum();
}
