import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';

class SubButton extends StatelessWidget {
  final String title;
  final Function onPressed;

  const SubButton(
      {Key? key, required this.title, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
          onPressed: () {
            onPressed();
          },
          child: Text(
            title,
            style: TextStyle(fontSize: 18,color: primaryColor),
          )),
    );
  }
}