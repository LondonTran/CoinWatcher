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

  int firstYAxisLabel;
  int secondYAxisLabel;
  int thirdYAxisLabel;

  @override
  void initState() {
    super.initState();
    isShowingSingleDataGraph = true;
  }

  List<FlSpot> getGraphData(String crypto) {
    List<double> prices = [];
    getGraphColor(crypto);
    getGraphPoints(crypto, prices);
    getMinAndMaxPrices(prices);
    getAxesLabels();
    return graphPoints[crypto];
  }

  void getGraphColor(String crypto) {
    switch (crypto) {
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

  void getGraphPoints(String crypto, List prices) {
    reversePricesAndTimes();
    extractPrices(crypto, prices);
    createGraphPoints(crypto, prices);
  }

  void reversePricesAndTimes() {
    widget.pricesAndTimes.forEach((key, value) {
      reversedPricesAndTimes[key] = value.reversed.toList();
    });
  }

  void extractPrices(String crypto, List<double> prices) {
    for (int j = 0; j < reversedPricesAndTimes[crypto].length; j++) {
      var pricesDouble =
          roundDouble(double.parse(reversedPricesAndTimes[crypto][j]), 2);
      prices.add(pricesDouble);
    }
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  void createGraphPoints(String crypto, List prices) {
    graphPoints[crypto] = prices.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();
  }

  void getMinAndMaxPrices(List<double> prices) {
    getMinAndMaxForSingleDataGraph(prices);
    getMinAndMaxForTripleDataGraph(prices);
  }

  void getMinAndMaxForSingleDataGraph(List<double> prices) {
    minY = prices.reduce(min);
    maxY = prices.reduce(max);
    maxX = prices.length.toDouble();
  }

  void getMinAndMaxForTripleDataGraph(List<double> prices) {
    minAndMaxForTripleDataGraph['min'].add(prices.reduce(min));
    minAndMaxForTripleDataGraph['max'].add(prices.reduce(max));

    minYForTripleDataGraph = minAndMaxForTripleDataGraph['min'].reduce(min);
    maxYForTripleDataGraph = minAndMaxForTripleDataGraph['max'].reduce(max);
  }

  void getAxesLabels() {
    setXAxisLabels();
    setYAxisLabels();
  }

  void setXAxisLabels() {
    firstXAxisLabel = (widget.pricesAndTimes['Times'].length / 3).floor();
    secondXAxisLabel =
        ((widget.pricesAndTimes['Times'].length * 2) / 3).floor();
  }

  // The operator x ~/ y is more efficient than (x / y).toInt().
  // Try re-writing the expression to use the '~/' operator.
  void setYAxisLabels() {
    firstYAxisLabel = (((maxY - minY) / 4) + minY).toInt();
    secondYAxisLabel = (((maxY - minY) / 2) + minY).toInt();
    thirdYAxisLabel = (((maxY - minY) * (3 / 4) + minY)).toInt();
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
            IconButton(
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
          ],
        ),
      ),
    );
  }

  LineChartData singleDataGraph() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
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
            //1st X-axis label 1/3 across
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
            fontSize: 16,
          ),
          getTitles: (value) {
            //Y AXIS

            // 1st Y-axis label 1/4 of the way up
            if (value.toInt() == firstYAxisLabel) {
              return formatNumber(firstYAxisLabel);
            }

            //2nd Y-axis label 1/2 of the way up
            if (value.toInt() == secondYAxisLabel) {
              return formatNumber(secondYAxisLabel);
            }

            //3rd Y-axis label 3/4 of the way up
            if (value.toInt() == thirdYAxisLabel) {
              return formatNumber(thirdYAxisLabel);
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
        spots: getGraphData(widget.crypto),
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
          interval: null,
          getTitles: (value) {
            //1st X-axis label 1/3 across
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
            if (value.toInt() == firstYAxisLabel) {
              return formatNumber(firstYAxisLabel);
            }

            //2nd Y-axis label 1/2 of the way up
            if (value.toInt() == secondYAxisLabel) {
              return formatNumber(secondYAxisLabel);
            }

            //3rd Y-axis label 3/4 of the way up
            if (value.toInt() == thirdYAxisLabel) {
              return formatNumber(thirdYAxisLabel);
            }
            return '';
          },
          margin: 10,
          reservedSize: 40,
          interval: null,
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
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final LineChartBarData bitcoinData = LineChartBarData(
      spots: getGraphData('BTC'),
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
      spots: getGraphData('ETH'),
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
      spots: getGraphData('LTC'),
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
