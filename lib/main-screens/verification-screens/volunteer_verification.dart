import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/main_button.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/home-screen/volunteer/volunteer_home_screen.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:sizer/sizer.dart';

class VolunteerEmailVerify extends StatefulWidget {
  const VolunteerEmailVerify({super.key});

  @override
  State<VolunteerEmailVerify> createState() => _VolunteerEmailVerifyState();
}

class _VolunteerEmailVerifyState extends State<VolunteerEmailVerify> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      UserSharedPreference.setUserRole('');
      sendVerificationEmail();
    }

    timer = Timer.periodic(
      Duration(seconds: 3),
      (_) => checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      showSnackBar(context, 'Verification email sent successfully!');

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      dialogueBox(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      UserSharedPreference.setUserRole('volunteer');
      return VolunteerHomeScreen();
    } else {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Verify email',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Image.asset(
                            'assets/images/login/email_verification.png',
                            height: 20.h,
                            width: 30.w,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 15),
                            child: Text(
                              'A verification mail has been sent to your email',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 20.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          MainButton(
                              title: 'Resend email',
                              onPressed: () async {
                                canResendEmail ? sendVerificationEmail() : null;
                              }),
                          SubButton(
                              title: 'Cancel',
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                goToDisableBack(context, LoginScreen());
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
