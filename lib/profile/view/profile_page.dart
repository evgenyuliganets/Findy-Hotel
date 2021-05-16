import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final int number;

  ProfilePage({this.number}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('My number is: $number'),
      ),
    );
  }
}