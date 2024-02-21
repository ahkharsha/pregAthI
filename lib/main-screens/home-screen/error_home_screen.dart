import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:sizer/sizer.dart';

class ErrorHomePage extends StatelessWidget {
  const ErrorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "pregAthI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'An unexpected error occured.',
              style: TextStyle(fontSize: 11.sp, color: Colors.black),
            ),
            Text(
              'Restart the app to continue',
              style: TextStyle(fontSize: 11.sp, color: Colors.black),
            )
          ],
        )),
      ),
    );
  }
}
