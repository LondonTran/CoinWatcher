const double kilo = 1000;

String formatNumber(int number) {
  String resultNumber;
  String symbol;
  if (number >= kilo) {
    resultNumber = ((number / kilo).floor()).toStringAsFixed(1);
    symbol = 'K';
  } else {
    resultNumber = number.toStringAsFixed(1);
    symbol = '';
  }

  if (resultNumber.endsWith('.0')) {
    resultNumber = resultNumber.substring(0, resultNumber.length - 2);
  }

  print("resultNumber + symbol");
  print(resultNumber + symbol);
  return resultNumber + symbol;
}
