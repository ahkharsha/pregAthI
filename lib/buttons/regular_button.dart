import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';

// ignore: must_be_immutable
class RegularButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  bool loading;
  RegularButton(
      {required this.title, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {onPressed();},
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            //fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
