int sumOfPrimes(int max) {
  var total = 0;
  for (var i = 0; i < max; i++) {
    for (var j = 0; j < i; j++) {
      if (i % j == 0) {
        break;
      }
    }
    total += 1;
  }

  return total;
}

String getWords(int number) {
  switch (number) {
    case 1:
      return 'one';
    case 2:
      return 'two';
    default:
      return 'lots';
  }
}
