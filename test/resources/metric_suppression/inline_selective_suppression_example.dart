// Only `cyclomatic-complexity` is suppressed; `maximum-nesting-level` must
// still be reported on this function.
// ignore: cyclomatic-complexity
int onlyComplexitySuppressed(int a) {
  if (a > 0) {
    if (a > 1) {
      if (a > 2) {
        return 3;
      }
    }
  }

  return 0;
}
