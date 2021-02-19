import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants.dart';
import 'dart:math';
import '../../services/format-number.dart';
import '../../services/get-x-axis-labels.dart';

class Graph extends StatefulWidget {
  Graph(this.pricesAndTimes, this.crypto, this.graphType);

  final Map<String, List<String>> pricesAndTimes;
  final String crypto;
  final String graphType;

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  bool isShowingSingleDataGraph;
  bool isFiveYearGraph;
  String timesVariable;
  Map<String, List<dynamic>> reversedPricesAndTimes = {};
  Map<String, List<FlSpot>> graphPoints = {
    'BTC': [],
    'ETH': [],
    'LTC': [],
  };

  Map<String, List<double>> minAndMaxForTripleDataGraph = {
    'min': [],
    'max': [],
  };

  double minY;
  double maxY;
  double maxX;

  double minYForTripleDataGraph;
  double maxYForTripleDataGraph;

  var graphColor;

  int firstXAxisLabel;
  int secondXAxisLabel;

  @override
  void initState() {
    super.initState();
    isShowingSingleDataGraph = true;
    checkIfGraphTypeIsFiveYearGraph(widget.graphType);
    getGraphData(widget.crypto);
  }

  void checkIfGraphTypeIsFiveYearGraph(String graphType) {
    if (graphType == '5Y') isFiveYearGraph = true;
    if (graphType != '5Y') isFiveYearGraph = false;
  }

  void getGraphData(String crypto) {
    Map<String, List<double>> prices = {'BTC': [], 'ETH': [], 'LTC': []};
    getGraphColor(crypto);
    getGraphPoints(crypto, prices);
    getMinAndMaxPrices(crypto, prices);
    getAxisLabels();
  }

  void getGraphColor(String crypto) {
    if (crypto == 'BTC') graphColor = bitcoinGraphColor;
    if (crypto == 'ETH') graphColor = ethereumGraphColor;
    if (crypto == 'LTC') graphColor = litecoinGraphColor;
  }

  void getGraphPoints(String crypto, Map<String, List<double>> prices) {
    reversePricesAndTimes();
    extractPrices(prices);
    createGraphPoints(prices);
  }

  void reversePricesAndTimes() {
    widget.pricesAndTimes.forEach((key, value) {
      reversedPricesAndTimes[key] = value.reversed.toList();
    });
  }

  void extractPrices(Map<String, List<double>> prices) {
    for (String crypto in cryptoAbbreviation) {
      for (int j = 0; j < reversedPricesAndTimes[crypto].length; j++) {
        var pricesDouble =
            roundDouble(double.parse(reversedPricesAndTimes[crypto][j]), 2);
        prices[crypto].add(pricesDouble);
      }
    }
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  void createGraphPoints(Map<String, List<double>> prices) {
    for (String crypto in cryptoAbbreviation) {
      graphPoints[crypto] = prices[crypto].asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value);
      }).toList();
    }
  }

  void getMinAndMaxPrices(String crypto, Map<String, List<double>> prices) {
    getMinAndMaxForSingleDataGraph(crypto, prices);
    getMinAndMaxForTripleDataGraph(prices);
  }

  void getMinAndMaxForSingleDataGraph(
      String crypto, Map<String, List<double>> prices) {
    minY = prices[crypto].reduce(min);
    maxY = prices[crypto].reduce(max);
    maxX = prices[crypto].length.toDouble();
  }

  void getMinAndMaxForTripleDataGraph(Map<String, List<double>> prices) {
    for (String crypto in cryptoAbbreviation) {
      minAndMaxForTripleDataGraph['min'].add(prices[crypto].reduce(min));
      minAndMaxForTripleDataGraph['max'].add(prices[crypto].reduce(max));

      minYForTripleDataGraph = minAndMaxForTripleDataGraph['min'].reduce(min);
      maxYForTripleDataGraph = minAndMaxForTripleDataGraph['max'].reduce(max);
    }
  }

  void getAxisLabels() {
    setXAxisLabels();
  }

  void setXAxisLabels() {
    firstXAxisLabel = (widget.pricesAndTimes['Times'].length / 3).floor();
    secondXAxisLabel =
        ((widget.pricesAndTimes['Times'].length * 2) / 3).floor();
  }

  double getYAxisInterval(double minY, double maxY) {
    var interval = ((maxY - minY) / 2).toDouble();
    return interval;
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
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 15.0, left: 6.0),
                    child: LineChart(
                      isShowingSingleDataGraph
                          ? singleDataGraph()
                          : tripleDataGraph(),
                      swapAnimationDuration: const Duration(milliseconds: 1),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            (isFiveYearGraph)
                ? IconButton(
                    icon: Icon(
                      Icons.loop_sharp,
                      color: Colors.white
                          .withOpacity(isShowingSingleDataGraph ? 1.0 : 0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        isShowingSingleDataGraph = !isShowingSingleDataGraph;
                      });
                    },
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  LineChartData singleDataGraph() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.cyan.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  '${reversedPricesAndTimes['Times'][flSpot.x.toInt()]} \n\n${flSpot.y.toStringAsFixed(2)}',
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
            if (value.toInt() == firstXAxisLabel) {
              return getXAxisLabels(firstXAxisLabel,
                  reversedPricesAndTimes['Times'], widget.graphType);
            }

            if (value.toInt() == secondXAxisLabel) {
              return getXAxisLabels(secondXAxisLabel,
                  reversedPricesAndTimes['Times'], widget.graphType);
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
            return formatNumber(value);
          },
          margin: 10,
          interval: getYAxisInterval(minY, maxY),
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
      minX: 0,
      maxX: maxX,
      maxY: maxY,
      minY: minY,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    return [
      LineChartBarData(
        spots: graphPoints[widget.crypto],
        isCurved: true,
        curveSmoothness: 0,
        gradientFrom: Offset(0.3, 0.9),
        gradientTo: Offset(1, 0),
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
            tooltipBgColor: Colors.cyan.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  '${barSpot.barIndex == 0 ? '${reversedPricesAndTimes['Times'][flSpot.x.toInt()]}\n\n' : ''} ${flSpot.y.toStringAsFixed(2)} ${cryptoAbbreviation[barSpot.barIndex]}',
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
            if (value.toInt() == firstXAxisLabel) {
              return getXAxisLabels(firstXAxisLabel,
                  reversedPricesAndTimes['Times'], widget.graphType);
            }

            // 2nd X-axis label 2/3 across
            if (value.toInt() == secondXAxisLabel) {
              return getXAxisLabels(secondXAxisLabel,
                  reversedPricesAndTimes['Times'], widget.graphType);
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
            return formatNumber(value);
          },
          margin: 10,
          reservedSize: 40,
          interval:
              getYAxisInterval(minYForTripleDataGraph, maxYForTripleDataGraph),
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
      minX: 0,
      maxX: maxX,
      maxY: maxYForTripleDataGraph,
      minY: minYForTripleDataGraph,
      lineBarsData: linesBarData2(),
    );
  }

  List<LineChartBarData> linesBarData2() {
    final LineChartBarData bitcoinData = LineChartBarData(
      spots: graphPoints['BTC'],
      isCurved: true,
      curveSmoothness: 0,
      colors: [
        bitcoinGraphColor,
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
      spots: graphPoints['ETH'],
      isCurved: true,
      curveSmoothness: 0,
      colors: [
        ethereumGraphColor,
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
      spots: graphPoints['LTC'],
      isCurved: true,
      curveSmoothness: 0,
      colors: [litecoinGraphColor],
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
