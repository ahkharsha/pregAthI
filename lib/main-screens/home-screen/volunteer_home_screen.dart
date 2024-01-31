import 'package:flutter/material.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/const/constants.dart';

class VolunteerHomeScreen extends StatelessWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("pregAthI",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Padding(
    padding: EdgeInsets.only(bottom: 20),
    child: ElevatedButton(
            onPressed: () {
              UserSharedPreference.setUserRole('');
              goTo(context, LoginScreen());
            },
            child: Padding(
              padding: EdgeInsets.all(0),
              child: Text(
                "Logout from Volunteer homescreen",
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
          ),
  ),
      ),
    );
  }
}
 