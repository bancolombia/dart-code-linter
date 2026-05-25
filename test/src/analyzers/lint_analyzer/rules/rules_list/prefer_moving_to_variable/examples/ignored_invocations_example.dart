extension NumExtension on num {
  double get h => this * 1.0;
  double get r => this * 1.0;
}

void main() {
  final a = 16.h;
  final b = 16.h;

  final c = 8.r;
  final d = 8.r;
}
