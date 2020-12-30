import 'package:bitcoin_ticker/constants.dart';

class PullData {
  PullData(this.cryptoCurrency, this.selectedCurrency, this.periodValue);

  String cryptoCurrency;
  String selectedCurrency;
  String periodValue;
  String beginningOfURL;
  String endOfURL;

  setURL() {
    beginningOfURL = '$cryptoAPIURL$cryptoCurrency$selectedCurrency';
    endOfURL = 'apikey=$apiKey';
  }

  pullPastPrice() {
    setURL();
    String pastPriceURL = '$beginningOfURL/ohlc?periods=$periodValue&$endOfURL';
    String currentPriceURL = '$beginningOfURL/price?$endOfURL';
  }
}

//cryptoCurrency
//selectedCurrency
//periodValue
