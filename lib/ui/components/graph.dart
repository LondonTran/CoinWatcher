import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants.dart';
import 'dart:math';
import '../../utils.dart';

class Graph extends StatefulWidget {
  Graph(
      this.closingTimesAndPrices, this.selectedCrypto, this.selectedGraphType);

  final Map<String, List<dynamic>> closingTimesAndPrices;
  final String selectedCrypto;
  final String selectedGraphType;

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  bool isShowingMainData;
  String timesVariable;
  List<String> closingTimes = [];
  List<String> priceStringList = [];
  Map<String, List<String>> closingPrices = {'BTC': [], 'ETH': [], 'LTC': []};
  Map<String, List<FlSpot>> cryptoSpots = {
    'BTC': [],
    'ETH': [],
    'LTC': [],
  };

  Map<String, List<double>> minAndMaxTriple = {
    'min': [],
    'max': [],
  };

  double minY;
  double maxY;
  double maxX;
  double factor;

  //min and max Y for triple data graphs
  double minYTriple;
  double maxYTriple;
  double factorTriple;

  var graphColor;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
    extractMap();
    getGraphColor(widget.selectedCrypto);
    getSpotData(widget.selectedCrypto, 'single');
  }

  //gets Min and Max axes for single data graphs
  void getMinAndMaxSingle(List<double> doubleList) {
    minY = doubleList.reduce(min);
    maxY = doubleList.reduce(max);
    maxX = doubleList.length.toDouble();
    factor = (maxY - minY) / 4;
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  //gets Min and Max axes for triple data graphs
  void getMinAndMaxTriple(List<double> doubleList) {
    minAndMaxTriple['min'].add(doubleList.reduce(min));
    minAndMaxTriple['max'].add(doubleList.reduce(max));

    minYTriple = minAndMaxTriple['min'].reduce(min);
    maxYTriple = minAndMaxTriple['max'].reduce(max);

    factorTriple = (maxYTriple - minYTriple) / 4;
    print("Inserted Y value");
    print(((minYTriple + 2 * factorTriple) ~/ 1000) * 1000);
  }

  void extractMap() {
    closingTimes = widget.closingTimesAndPrices['Times'].reversed.toList();

    for (int j = 0; j < cryptoAbbreviation.length; j++) {
      closingPrices[cryptoAbbreviation[j]] =
          widget.closingTimesAndPrices[cryptoAbbreviation[j]];
    }
  }

//TODO: Use factory method/polymorphism to shrink this switch statement
  void getGraphColor(String selectedCrypto) {
    switch (selectedCrypto) {
      case 'BTC':
        graphColor = bitcoinGraphColor;
        break;
      case 'ETH':
        graphColor = ethereumGraphColor;
        break;
      case 'LTC':
        graphColor = litecoinGraphColor;
        break;
    }
  }

  List<FlSpot> getSpotData(String crypto, String flag) {
    priceStringList = closingPrices[crypto].reversed.toList();

    List<double> doubleList = [];
    print("priceStringList");
    print(priceStringList);

    //converts String List of prices to List of Double prices
    for (int j = 0; j < priceStringList.length; j++) {
      var doubleData = roundDouble(double.parse(priceStringList[j]), 2);
      doubleList.add(doubleData);
    }

    print("doubleList");
    print(doubleList);
    if (flag == 'single') {
      getMinAndMaxSingle(doubleList);
    } else if (flag == 'triple') {
      getMinAndMaxTriple(doubleList);
    }

    // adds x-coordinate to price data to fit on graph. ex: 10.50 -> (0.0, 10.50)
    cryptoSpots[crypto] = doubleList.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return cryptoSpots[crypto];
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: const [
              Color(0xff2c274c),
              Color(0xff46426c),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 37,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                    child: LineChart(
                      isShowingMainData ? singleDataGraph() : tripleDataGraph(),
                      swapAnimationDuration: const Duration(milliseconds: 250),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.loop_sharp,
                color: Colors.white.withOpacity(isShowingMainData ? 1.0 : 0.5),
              ),
              onPressed: () {
                setState(() {
                  isShowingMainData = !isShowingMainData;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  LineChartData singleDataGraph() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            /////////////////////////////////////////
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  '${closingTimes[flSpot.x.toInt()]} \n\n${flSpot.y.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            }),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          interval: 1,
          getTitles: (value) {
            //1st X-axis label 1/3 across
            //Can I combine these if statements to an if-else if?
            if (value.toInt() == (closingTimes.length / 3).floor()) {
              return getXAxisLabels(
                  'first', closingTimes, widget.selectedGraphType);
            }

            // 2nd X-axis label 2/3 across
            if (value.toInt() == ((closingTimes.length * 2) / 3).floor()) {
              // return closingTimes[0].toString();
              return getXAxisLabels(
                  'second', closingTimes, widget.selectedGraphType);
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          getTitles: (value) {
            //3rd Y-axis label 3/4 of the way up
            if (value.toInt() == (maxY - factor)) {
              return formatNumber((maxY - factor));
            }

            //2nd Y-axis label 1/2 of the way up
            if (value.toInt() == (minY + 2 * factor).floor()) {
              return formatNumber((minY + 2 * factor));
            }

            // 1st Y-axis label 1/4 of the way up
            if (value.toInt() == (minY + factor).floor()) {
              return formatNumber((minY + factor));
              // return (maxY - factor).floor().toString();
            }

            return '';
          },
          margin: 10,
          interval: 1,
          reservedSize: 40,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      //////////////////////////////////////////////////////////////////////////////////////
      minX: 0,
      maxX: maxX,
      maxY: maxY,
      minY: minY,
      lineBarsData: linesBarData2(),
    );
  }

  List<LineChartBarData> linesBarData2() {
    return [
      LineChartBarData(
        spots: getSpotData(widget.selectedCrypto, 'single'),
        isCurved: true,
        curveSmoothness: 0,
        colors: [
          graphColor,
        ],
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    ];
  }

  LineChartData tripleDataGraph() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  '${flSpot.y.toStringAsFixed(2)}',
                  // '${closingTimes[flSpot.x.toInt()]} \n\n${flSpot.y}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            }),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          interval: 1,
          getTitles: (value) {
            //1st X-axis label 1/3 across
            //Can I combine these if statements to an if-else if?
            if (value.toInt() == (closingTimes.length / 3).floor()) {
              return getXAxisLabels(
                  'first', closingTimes, widget.selectedGraphType);
            }

            // 2nd X-axis label 2/3 across
            if (value.toInt() == ((closingTimes.length * 2) / 3).floor()) {
              // return closingTimes[0].toString();
              return getXAxisLabels(
                  'second', closingTimes, widget.selectedGraphType);
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            //Instead of using "factor" and adding/subtracting it to/from min/maxY,
            // take MaxY and multiply it by 0.75, 0.5, and 0.25
            //and display that number instead

            //3rd Y-axis label 3/4 of the way up

            if (value.toInt() == ((maxYTriple - factorTriple) ~/ 1000) * 1000) {
              return formatNumber((maxYTriple - factorTriple));
            }

            //2nd Y-axis label 1/2 of the way up
            if (value.toInt() ==
                ((minYTriple + 2 * factorTriple) ~/ 1000) * 1000) {
              return formatNumber((minYTriple + 2 * factorTriple));
            }

            // 1st Y-axis label 1/4 of the way up
            if (value.toInt() == ((minYTriple + factorTriple) ~/ 1000) * 1000) {
              return formatNumber((minYTriple + factorTriple));
            }

            // if (value.toInt() == (maxY - factor).floor()) {
            //   return formatNumber((maxY - factor));
            // }
            //
            // //2nd Y-axis label 1/2 of the way up
            // if (value.toInt() == (minY + 2 * factor).floor()) {
            //   return formatNumber((minY + 2 * factor));
            // }
            //
            // // 1st Y-axis label 1/4 of the way up
            // if (value.toInt() == (minY + factor).floor()) {
            //   return formatNumber((minY + factor));
            //   return (maxY - factor).floor().toString();
            // }
            //

            // switch (value.toInt()) {
            //   case 10000:
            //     return '1m';
            //   case 11000:
            //     return '2m';
            //   case 13000:
            //     return '3m';
            //   case 16000:
            //     return '5m';
            // }
            return '';
          },
          margin: 10,
          reservedSize: 40,
          interval: 100,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      //////////////////////////////////////////////////////////////////////////////////////
      minX: 0,
      maxX: maxX,
      maxY: maxYTriple,
      minY: minYTriple,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final LineChartBarData bitcoinData = LineChartBarData(
      spots: getSpotData('BTC', 'triple'),
      isCurved: true,
      curveSmoothness: 0,
      colors: [
        const Color(0xff4af699),
      ],
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    final LineChartBarData ethereumData = LineChartBarData(
      spots: getSpotData('ETH', 'triple'),
      isCurved: true,
      curveSmoothness: 0,
      colors: [
        const Color(0xffaa4cfc),
      ],
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    final LineChartBarData litecoinData = LineChartBarData(
      spots: getSpotData('LTC', 'triple'),
      isCurved: true,
      curveSmoothness: 0,
      colors: [
        const Color(0xff27b6fc),
      ],
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    return [
      bitcoinData,
      ethereumData,
      litecoinData,
    ];
  }
}
