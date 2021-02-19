import 'package:flutter/material.dart';
import 'dart:ui';

const List<String> cryptoAbbreviation = ['BTC', 'ETH', 'LTC'];
const List<String> cryptoName = ['Bitcoin', 'Ethereum', 'Litecoin'];
const List<String> currenciesList = [
  'USD',
  'EUR',
  'GBP',
];

const List<String> graphTypeList = ['1D', '5D', '1M', '1Y', '5Y'];
const cryptoAPIURL = 'https://api.cryptowat.ch/markets/kraken/';
const apiKey = 'YOUR-API-KEY-HERE';

const bitcoinGraphColor = Color(0xffff6e69);
const ethereumGraphColor = Color(0xffaa4cfc);
const litecoinGraphColor = Color(0xff27b6fc);

const double billion = 1000000000;
const double million = 1000000;
const double kilo = 1000;
