import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../constants.dart';

class CryptoCard extends StatefulWidget {
  CryptoCard(
    this.currency,
    this.value,
    this.name,
    this.icon,
  );

  final String currency;
  final String value;
  final String name;
  final icon;

  // 1. reverse pricesAndTimes and save it into a new variable

  // 1. initState runs getSpotData(widget.crypto, 'single');
  // 2. getSpotData(widget.crypto, 'single');
  // The prices must be of type double at the end.

  @override
  _CryptoCardState createState() => _CryptoCardState();
}

class _CryptoCardState extends State<CryptoCard> {
  var graphColor;

  @override
  void initState() {
    super.initState();
    getGraphColor(widget.name);
  }

  void getGraphColor(String crypto) {
    switch (crypto) {
      case 'Bitcoin':
        graphColor = bitcoinGraphColor;
        break;
      case 'Ethereum':
        graphColor = ethereumGraphColor;
        break;
      case 'Litecoin':
        graphColor = litecoinGraphColor;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 00.0, 0.0, 0),
      child: Card(
        color: graphColor,
        // elevation: 5.0,
        shadowColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Text('${widget.name}'),
                ],
              ),
              Row(
                children: [
                  widget.icon,
                ],
              ),
              Row(
                children: [
                  Text('${widget.value} ${widget.currency}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
