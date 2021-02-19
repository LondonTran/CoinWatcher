import 'package:coin_watcher/ui/screens/price-screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          primaryColor: Color(0xff2c274c),
          scaffoldBackgroundColor: Color(0xff2c274c)),
      home: PriceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
