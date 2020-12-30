import 'package:bitcoin_ticker/data/coin_data.dart';
import 'package:bitcoin_ticker/ui/components/crypto_card.dart';
import 'package:bitcoin_ticker/ui/components/graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../constants.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';

class PriceScreen extends StatefulWidget {
  @override
  PriceScreenState createState() => PriceScreenState();
}

class PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  String selectedGraphType = '5Y';
  String selectedCrypto = 'LTC';
  Map<String, List<String>> closingTimesAndClosingPrices = {};
  Future<Map> futureData;

  var isSelectedCrypto = <bool>[false, false, true];
  var isSelectedGraph = <bool>[false, false, false, false, true];
  var isSelectedCurrency = <bool>[true, false, false];

  Future<Map> getData() async {
    try {
      closingTimesAndClosingPrices =
          await CoinData(selectedCurrency, selectedGraphType).getCoinData();
    } catch (e) {
      //TODO: Message and retry button if data not fetched in 10 seconds
      print(e);
    }
    return closingTimesAndClosingPrices;
  }

  @override
  void initState() {
    super.initState();
    futureData = getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Watcher'),
      ),
      body: FutureBuilder<Object>(
          future: futureData,
          builder: (context, snapshot) {
            return Stack(
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Expanded(
                      //     child: (snapshot.connectionState ==
                      //         ConnectionState.waiting)
                      //         ? Container()
                      //         : Graph(snapshot.data, selectedCrypto)),

                      Center(
                          child: ToggleButtons(
                        borderWidth: 10,
                        children: <Widget>[
                          CryptoCard(
                            selectedCurrency,
                            snapshot.connectionState == ConnectionState.waiting
                                ? '---'
                                : closingTimesAndClosingPrices[
                                    'currentCoinPrices'][0],
                            'Bitcoin',
                            Icon(CryptoFontIcons.BTC),
                          ),
                          CryptoCard(
                              selectedCurrency,
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? '---'
                                  : closingTimesAndClosingPrices[
                                      'currentCoinPrices'][1],
                              'Ethereum',
                              Icon(CryptoFontIcons.ETH)),
                          CryptoCard(
                              selectedCurrency,
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? '---'
                                  : closingTimesAndClosingPrices[
                                      'currentCoinPrices'][2],
                              'Litecoin',
                              Icon(CryptoFontIcons.LTC)),
                          // Cards(
                          //         isWaiting:
                          //             snapshot.connectionState ==
                          //                 ConnectionState.waiting,
                          //         selectedCurrency:
                          //             selectedCurrency,
                          //         coinData: coinData)
                          //     .makeCards(),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelectedCrypto.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelectedCrypto[buttonIndex] = true;
                                selectedCrypto =
                                    cryptoAbbreviation[buttonIndex];
                                print("selectedCrypto");
                                print(selectedCrypto);
                              } else {
                                isSelectedCrypto[buttonIndex] = false;
                              }
                            }
                          });

                          futureData = getData();
                        },
                        isSelected: isSelectedCrypto,
                        selectedColor: Colors.amber,
                        renderBorder: false,
                        fillColor: Colors.transparent,
                      )),
                      // MakeCards(
                      // isWaiting: snapshot.connectionState ==
                      // ConnectionState.waiting,
                      // selectedCurrency: selectedCurrency,
                      // coinData: coinData)
                      //     .makeCards(),
                      Center(
                        child: ToggleButtons(
                          borderWidth: 0.0,
                          splashColor: null,
                          renderBorder: false,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('1D'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('5D'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('1M'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('1Y'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('5Y'),
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < isSelectedGraph.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  isSelectedGraph[buttonIndex] = true;
                                  selectedGraphType = graphType[buttonIndex];
                                  print("selectedGraphType");
                                  print(selectedGraphType);
                                } else {
                                  isSelectedGraph[buttonIndex] = false;
                                }
                              }
                            });
                            futureData = getData();
                          },
                          isSelected: isSelectedGraph,
                        ),
                      ),
                      Expanded(
                          child: (snapshot.connectionState ==
                                  ConnectionState.waiting)
                              ? Container()
                              : Graph(snapshot.data, selectedCrypto,
                                  selectedGraphType)),
                      Center(
                          //When refactoring this later, use the text of buttons 'USD', etc. and pass as parameters. Something like this: ToggleButtons('USD', 'EUR', 'GBP') or better yet ToggleButtons(currenciesList)
                          child: ToggleButtons(
                        borderWidth: 0.0,
                        splashColor: null,
                        renderBorder: false,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('USD'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('EUR'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('GBP'),
                          ),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelectedCurrency.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelectedCurrency[buttonIndex] = true;
                                selectedCurrency = currenciesList[buttonIndex];
                              } else {
                                isSelectedCurrency[buttonIndex] = false;
                              }
                            }
                            futureData = getData();
                          });
                        },
                        isSelected: isSelectedCurrency,
                      )),
                    ]),
                // if  {
                Center(
                    child: (snapshot.connectionState == ConnectionState.waiting)
                        ? CircularProgressIndicator()
                        : Container())
              ],
            );
          }),
    );
  }
}
