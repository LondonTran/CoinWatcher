import 'package:bitcoin_ticker/constants.dart';

class URLBuilder {
  URLBuilder(this.cryptoCurrency, this.currency, this.periodValue);

  String cryptoCurrency;
  String currency;
  String periodValue;

  String _pricesAndTimesURL;

  String get pricesAndTimesURL => _pricesAndTimesURL;
  // https://api.cryptowat.ch/markets/kraken/btcusd/ohlc?periods=86400&apikey=XXXXXXXXXXXXXXXXXX

  buildURL() {
    _pricesAndTimesURL =
        'https://api.cryptowat.ch/markets/kraken/$cryptoCurrency$currency/ohlc?periods=$periodValue&apikey=$apiKey';
  }
}
