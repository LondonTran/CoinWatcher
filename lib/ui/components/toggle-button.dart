import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  ToggleButton(this.title);

  final String title;

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text('${widget.title}'),
    );
  }
}
