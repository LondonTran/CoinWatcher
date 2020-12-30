import 'dart:convert';
import '../constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../DataPointsHelper.dart';

class CoinData {
  CoinData(this.selectedCurrency, this.selectedGraphType);

  String selectedCurrency;
  String selectedGraphType;
  String periodValue;
  int numberOfDataPoints;
  Map<String, List<String>> closingTimesAndClosingPrices = {
    'currentCoinPrices': [],
    'Times': [],
    'BTC': [],
    'ETH': [],
    'LTC': []
  };
  bool isFirstLoop = true;

  String fetchClosePrice(
      int closeTime, String closePrice, String cryptoCurrency) {
    //TODO converts closeTime UNIX code to String
    DateTime closingTime =
    new DateTime.fromMillisecondsSinceEpoch(closeTime * 1000);
    final template = DateFormat('EEE, MMM d ' 'yyyy h:mm a');
    final formattedClosingTime = template.format(closingTime); //String

    closingTimesAndClosingPrices[cryptoCurrency].add(closePrice);

    return formattedClosingTime;
  }

  void processDataPoints(List historicalPrice, String cryptoCurrency) {
    for (int j = 1; j < numberOfDataPoints; j++) {
      var closeTime = historicalPrice[historicalPrice.length - j][0]; //int
      String closePrice =
      historicalPrice[historicalPrice.length - j][4].toString(); //double

      String formattedClosingTime =
      fetchClosePrice(closeTime, closePrice, cryptoCurrency);
      //TODO adds closingTimes to Map
      if (isFirstLoop) {
        closingTimesAndClosingPrices['Times'].add(formattedClosingTime);
      }
    }
  }

  void processHistoricalResponse(
      http.Response historicalResponse, String cryptoCurrency) {
    var decodedHistorical = jsonDecode(historicalResponse.body);
    List historicalPrice = decodedHistorical['result'][periodValue];

    processDataPoints(historicalPrice, cryptoCurrency);

    //TODO gets and assigns current coin prices
    String currentCoinPrice =
    historicalPrice[historicalPrice.length - 1][4].toString();
    closingTimesAndClosingPrices['currentCoinPrices'].add(currentCoinPrice);

    isFirstLoop = false;
  }

  void processHistoricalResponseForCurrency(
      http.Response historicalResponse, String cryptoCurrency) {
    if (historicalResponse.statusCode == 200) {
      processHistoricalResponse(historicalResponse, cryptoCurrency);
    } else {
      throw 'Problem retrieving data. Please check your connection';
    }
  }

  Future getCoinData() async {
    DataPointsHelper dataPointsHelper = DataPointsHelper(selectedGraphType);

    dataPointsHelper.decideNumberOfDataPoints();
    periodValue = dataPointsHelper.periodValue;
    numberOfDataPoints = dataPointsHelper.numberOfDataPoints;

    for (String cryptoCurrency in cryptoAbbreviation) {
      //TODO gets proper URLS to pull from with each crypto abbreviation above

      String historicalRequestURL =
          '$cryptoAPIURL$cryptoCurrency$selectedCurrency/ohlc?periods=$periodValue&apikey=$apiKey';
      http.Response historicalResponse = await http.get(historicalRequestURL);

      processHistoricalResponseForCurrency(historicalResponse, cryptoCurrency);
    } //for
    print('closingTimesAndClosingPrices');
    print(closingTimesAndClosingPrices);
    return closingTimesAndClosingPrices; //{currentCoinPrice: [], Times: [Fri, Oct 30 2020...
  }
}
