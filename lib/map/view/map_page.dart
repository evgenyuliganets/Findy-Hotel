import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  final int number;

  MapPage({this.number}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('My number is: $number'),
      ),
    );
  }
}