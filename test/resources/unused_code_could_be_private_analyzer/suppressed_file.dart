// ignore_for_file: unused-code

class WhollySuppressed {
  int member() => 1;

  int callIt() => member();
}

void main() {
  WhollySuppressed().callIt();
}
