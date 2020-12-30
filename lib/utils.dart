import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'ui/components/graph.dart';

const double kilo = 1000;

String formatNumber(double number) {
  String resultNumber;
  String symbol;
  if (number >= kilo) {
    resultNumber = ((number / kilo).floor()).toStringAsFixed(1);
    symbol = 'K';
  } else {
    resultNumber = number.toStringAsFixed(1);
    symbol = '';
  }

  if (resultNumber.endsWith('.0')) {
    resultNumber = resultNumber.substring(0, resultNumber.length - 2);
  }

  return resultNumber + symbol;
}

//TODO: Use factory method/polymorphism to shrink this switch statement
String getXAxisLabels(
    String firstOrSecond, List<String> closingTimes, String selectedGraphType) {
  //1st X-axis label 1/3 of the way across
  int firstLabel = (closingTimes.length / 3).floor();

  //2nd X-axis label 2/3 of the way across
  int secondLabel = ((closingTimes.length * 2) / 3).floor();

  String label;

  switch (selectedGraphType) {
    case '1D':
      if (firstOrSecond == 'first') {
        label = closingTimes[firstLabel].substring(16, closingTimes[96].length);
      } else if (firstOrSecond == 'second') {
        label =
            closingTimes[secondLabel].substring(16, closingTimes[192].length);
      }
      break;

    case '5D':
      if (firstOrSecond == 'first') {
        label = closingTimes[firstLabel]
            .substring(5, closingTimes[firstLabel].length - 13);
      } else if (firstOrSecond == 'second') {
        label = closingTimes[secondLabel]
            .substring(5, closingTimes[firstLabel].length - 13);
      }
      break;

    case '1M':
      if (firstOrSecond == 'first') {
        label = closingTimes[firstLabel]
            .substring(5, closingTimes[firstLabel].length - 13);
      } else if (firstOrSecond == 'second') {
        label = closingTimes[secondLabel]
            .substring(5, closingTimes[firstLabel].length - 13);
      }
      break;

    case '1Y':
      if (firstOrSecond == 'first') {
        label = closingTimes[firstLabel]
            .substring(5, closingTimes[firstLabel].length - 13);
      } else if (firstOrSecond == 'second') {
        label = closingTimes[secondLabel]
            .substring(5, closingTimes[firstLabel].length - 13);
      }
      break;

    case '5Y':
      if (firstOrSecond == 'first') {
        label = closingTimes[firstLabel]
            .substring(5, closingTimes[firstLabel].length - 7);
      } else if (firstOrSecond == 'second') {
        label = closingTimes[secondLabel]
            .substring(5, closingTimes[firstLabel].length - 7);
      }
      break;
  }
  return label;
  // String test = "Hello";
  // return test;
}
