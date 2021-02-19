import 'dart:convert';
import '../constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/data-points-helper.dart';
import '../services/url-builder.dart';

class CoinData {
  CoinData(this.currency, this.graphType);

  String currency;
  String graphType;

  String periodValue;
  int numberOfDataPoints;
  http.Response pricesAndTimesResponse;
  bool isPullSuccessful;
  bool isFirstLoop = true;
  Map<String, List<String>> pricesAndTimes = {
    'currentCoinPrices': [],
    'Times': [],
    'BTC': [],
    'ETH': [],
    'LTC': []
  };

  Future<Map<String, List<String>>> getCoinData() async {
    calculateNumberOfDataPoints();
    await pullPricesAndTimes();
    return pricesAndTimes;
  }

  void calculateNumberOfDataPoints() {
    DataPointsHelper dataPointsHelper = DataPointsHelper(graphType);
    dataPointsHelper.assignNumberOfDataPoints();
    periodValue = dataPointsHelper.periodValue;
    numberOfDataPoints = dataPointsHelper.numberOfDataPoints;
  }

  Future<void> pullPricesAndTimes() async {
    for (String crypto in cryptoAbbreviation) {
      await pullDataFromAPI(crypto);
      processData(crypto);
    }
  }

  Future<void> pullDataFromAPI(String crypto) async {
    URLBuilder urlBuilder = URLBuilder(crypto, currency, periodValue);
    urlBuilder.buildURL();
    String pricesAndTimesURL = urlBuilder.pricesAndTimesURL;
    pricesAndTimesResponse = await http.get(pricesAndTimesURL);
    isPullSuccessful = (pricesAndTimesResponse.statusCode == 200);
  }

  void processData(String crypto) {
    if (isPullSuccessful) {
      var decodedData = jsonDecode(pricesAndTimesResponse.body);
      List priceAndTimeData = decodedData['result'][periodValue];
      selectCurrentPriceData(priceAndTimeData);
      sortGraphData(priceAndTimeData, crypto);
    } else {
      throw 'Problem pulling data';
    }
  }

  void selectCurrentPriceData(List priceAndTimeData) {
    String currentPrice =
        priceAndTimeData[priceAndTimeData.length - 1][4].toStringAsFixed(2);
    pricesAndTimes['currentCoinPrices'].add(currentPrice);
  }

  void sortGraphData(List priceAndTimeData, String crypto) {
    for (int j = 1; j < numberOfDataPoints; j++) {
      selectGraphPriceData(j, priceAndTimeData, crypto);
      if (isFirstLoop) {
        selectGraphTimeData(j, priceAndTimeData);
      }
    }
    isFirstLoop = false;
  }

  void selectGraphPriceData(int j, List priceAndTimeData, String crypto) {
    String graphPrice =
        priceAndTimeData[priceAndTimeData.length - j][4].toString();
    pricesAndTimes[crypto].add(graphPrice);
  }

  void selectGraphTimeData(int j, List priceAndTimeData) {
    var utcTimeStamp = priceAndTimeData[priceAndTimeData.length - j][0];
    pricesAndTimes['Times'].add(convertUTCtoTimeString(utcTimeStamp));
  }

  String convertUTCtoTimeString(utcTimeStamp) {
    DateTime timeAndDate =
        new DateTime.fromMillisecondsSinceEpoch(utcTimeStamp * 1000);
    final template = DateFormat('EEE, MMM d ' 'yyyy h:mm a');
    final formattedTimeAndDate = template.format(timeAndDate);
    return formattedTimeAndDate;
  }
}
