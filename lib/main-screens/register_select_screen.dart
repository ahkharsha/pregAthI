import 'package:flutter/material.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/navigators.dart';
import 'package:pregathi/widgets/register/display_volunteer_register.dart';
import 'package:pregathi/widgets/register/display_wife_register.dart';
import 'package:sizer/sizer.dart';

class RegisterSelectScreen extends StatelessWidget {
  const RegisterSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 7.h,),
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DisplayWifeRegister(),
                      DisplayVolunteerRegister(),
                    ],
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: SubButton(
                        title: 'Already have an account? Login',
                        onPressed: () => navigateToLogin(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
