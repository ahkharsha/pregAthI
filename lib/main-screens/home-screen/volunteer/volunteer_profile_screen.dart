import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/home-screen/volunteer_home_screen.dart';

class VolunteerProfileScreen extends StatelessWidget {
  const VolunteerProfileScreen({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              goTo(context, VolunteerHomeScreen());
            }),
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Text('Volunteer Profile Screen'),
      ),
    );
  }
}
