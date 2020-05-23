import 'package:flutter/material.dart';
import 'package:stocktake/screens/home_page.dart';

void main() {
  runApp(Stocktake());
}

class Stocktake extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stocktake',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
