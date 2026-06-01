// `suppressedAbove` uses an inline `// ignore:` comment on the line above.
// ignore: cyclomatic-complexity
int suppressedAbove(int a) {
  if (a > 0) {
    if (a > 1) {
      if (a > 2) {
        return 3;
      }
    }
  }

  return 0;
}

// `suppressedTrailing` uses a trailing `// ignore:` comment.
int suppressedTrailing(int a) { // ignore: cyclomatic-complexity
  if (a > 0) {
    if (a > 1) {
      if (a > 2) {
        return 3;
      }
    }
  }

  return 0;
}

// `notSuppressed` has no ignore comment and must still be reported.
int notSuppressed(int a) {
  if (a > 0) {
    if (a > 1) {
      if (a > 2) {
        return 3;
      }
    }
  }

  return 0;
}
