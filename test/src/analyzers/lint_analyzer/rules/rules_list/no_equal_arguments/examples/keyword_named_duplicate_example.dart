void configure({Object? on, Object? other}) {}

void main() {
  final shared = Object();
  configure(on: shared, other: shared); // LINT
}
