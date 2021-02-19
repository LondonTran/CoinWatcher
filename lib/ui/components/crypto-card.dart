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
    if (crypto == 'Bitcoin') graphColor = bitcoinGraphColor;
    if (crypto == 'Ethereum') graphColor = ethereumGraphColor;
    if (crypto == 'Litecoin') graphColor = litecoinGraphColor;
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
