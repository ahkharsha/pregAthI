import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.white),
        title: Text(
          "Work",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      body: Center(child: Text('Preg news screen')),);
  }
}