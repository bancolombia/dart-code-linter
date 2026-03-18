// ignore_for_file: cyclomatic-complexity, maximum-nesting-level

int deepComplexFunction(int a) {
  if (a > 0) {
    if (a > 1) {
      if (a > 2) {
        return 3;
      }

      return 2;
    }

    return 1;
  } else if (a < 0) {
    return -1;
  }

  return 0;
}
