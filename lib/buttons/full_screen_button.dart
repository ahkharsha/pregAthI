import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';

// ignore: must_be_immutable
class FullScreenButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  bool loading;
  FullScreenButton(
      {required this.title, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            //fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
      ),
    );
  }
}
