import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';

class VariableButton extends StatelessWidget {
  final String title;
  final Function onPressed;

  const VariableButton(
      {Key? key, required this.title, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}