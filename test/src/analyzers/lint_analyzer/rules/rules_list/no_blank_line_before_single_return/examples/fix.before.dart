// ignore_for_file: always_put_control_body_on_new_line, newline-before-return
int f(int a) {
  if (a > 1) {

    return a + 1;
  }

  if (a > 2) {

    // a comment
    return a + 2;
  }

  if (a > 3) {

    // first comment
    // second comment
    return a + 3;
  }

  if (a > 4) {

    /*
     * block comment
     */
    return a + 4;
  }

  if (a > 5) {
    // comment after brace

    return a + 5;
  }

  if (a > 6) {

    // comment between blanks

    return a + 6;
  }

  if (a > 7) {

    // first comment

    // second comment
    return a + 7;
  }

  if (a > 8) {



    return a + 8;
  }

  return a;
}
