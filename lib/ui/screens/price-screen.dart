import 'package:coin_watcher/data/coin-data.dart';
import 'package:coin_watcher/ui/components/crypto-card.dart';
import 'package:coin_watcher/ui/components/graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../constants.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';
import '../components/toggle-button.dart';

class PriceScreen extends StatefulWidget {
  @override
  PriceScreenState createState() => PriceScreenState();
}

class PriceScreenState extends State<PriceScreen> {
  String currency = 'USD';
  String graphType = '5Y';
  String crypto = 'BTC';
  Map<String, List<String>> pricesAndTimes = {};
  Future<Map> futureData;

  var isSelectedCrypto = <bool>[true, false, false];
  var isSelectedGraph = <bool>[false, false, false, false, true];
  var isSelectedCurrency = <bool>[true, false, false];

  Future<Map> getData() async {
    try {
      pricesAndTimes = await CoinData(currency, graphType).getCoinData();
    } catch (e) {
      print(e);
    }
    return pricesAndTimes;
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
        title: Text('Coin Watcher'),
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
                      Center(
                          child: ToggleButtons(
                        borderWidth: 10,
                        children: <Widget>[
                          CryptoCard(
                            currency,
                            snapshot.connectionState == ConnectionState.waiting
                                ? '---'
                                : pricesAndTimes['currentCoinPrices'][0],
                            'Bitcoin',
                            Icon(CryptoFontIcons.BTC),
                          ),
                          CryptoCard(
                              currency,
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? '---'
                                  : pricesAndTimes['currentCoinPrices'][1],
                              'Ethereum',
                              Icon(CryptoFontIcons.ETH)),
                          CryptoCard(
                              currency,
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? '---'
                                  : pricesAndTimes['currentCoinPrices'][2],
                              'Litecoin',
                              Icon(CryptoFontIcons.LTC)),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelectedCrypto.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelectedCrypto[buttonIndex] = true;
                                crypto = cryptoAbbreviation[buttonIndex];
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
                      Center(
                        child: ToggleButtons(
                          borderWidth: 0.0,
                          splashColor: null,
                          renderBorder: false,
                          children: <Widget>[
                            ToggleButton('1D'),
                            ToggleButton('5D'),
                            ToggleButton('1M'),
                            ToggleButton('1Y'),
                            ToggleButton('5Y'),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < isSelectedGraph.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  isSelectedGraph[buttonIndex] = true;
                                  graphType = graphTypeList[buttonIndex];
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
                              : Graph(snapshot.data, crypto, graphType)),
                      Center(
                          child: ToggleButtons(
                        borderWidth: 0.0,
                        splashColor: null,
                        renderBorder: false,
                        children: <Widget>[
                          ToggleButton('USD'),
                          ToggleButton('EUR'),
                          ToggleButton('GBP'),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelectedCurrency.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelectedCurrency[buttonIndex] = true;
                                currency = currenciesList[buttonIndex];
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
