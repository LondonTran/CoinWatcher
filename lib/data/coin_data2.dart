// import 'dart:convert';
// import '../constants.dart';
// import 'package:http/http.dart' as http;
//
// class CoinData {
//   Future getCoinData(String selectedCurrency) async {
//     List<String> cryptoPrices = [];
//
//     for (String crypto in cryptoAbbreviation) {
//       String priceRequestURL =
//           '$cryptoAPIURL$crypto$selectedCurrency/price?apikey=$apiKey';
//       http.Response priceResponse = await http.get(priceRequestURL);
//
//       if (priceResponse.statusCode == 200) {
//         var decodedPrice = jsonDecode(priceResponse.body);
//         var price = decodedPrice['result']['price'];
//
//         cryptoPrices.add(price.toStringAsFixed(2));
//       } else {
//         print(priceResponse.statusCode);
//         throw 'Problem with retrieving coin data';faa
//       }
//     }
//     print(selectedCurrency);
//     return cryptoPrices;
//   }
// }
