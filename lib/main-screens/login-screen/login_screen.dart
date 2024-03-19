import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/buttons/main_button.dart';
import 'package:pregathi/navigators.dart';
import 'package:pregathi/widgets/textfield.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formKey.currentState!.save();
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _formData['email'].toString(),
              password: _formData['password'].toString());
      if (userCredential.user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .then((userData) {
          if (userData['role'] == 'wife') {
            UserSharedPreference.setUserRole('wife');
            navigateToWifeEmailVerify(context);
            print(userData['role']);
          } else if (userData['role'] == 'volunteer') {
            UserSharedPreference.setUserRole('volunteer');
            print(userData['role']);
            navigateToVolunteerEmailVerify(context);
          } else {
            UserSharedPreference.setUserRole('');
            navigateToErrorHome(context);
          }
          setState(() {
            isLoading = false;
          });
        });
      }
    }
    // on FirebaseAuthException catch (e) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   if (e.code == 'user-not-found') {
    //     dialogueBox(context, 'No user found for that email.');
    //     print('No user found for that email.');
    //   } else if (e.code == 'wrong-password') {
    //     dialogueBox(context, 'Wrong password provided for that user.');
    //     print('Wrong password provided for that user.');
    //   }
    // }
    catch (e) {
      setState(() {
        isLoading = false;
      });
      dialogueBox(context, 'Error logging in. Incorrect email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              isLoading
                  ? progressIndicator(context)
                  : Center(
                    child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'User Login',
                                    style: TextStyle(
                                      fontSize: 35.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/login/login_logo.png',
                                    height: 20.h,
                                    width: 30.w,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomTextField(
                                      hintText: 'Enter Email',
                                      textInputAction: TextInputAction.next,
                                      keyboardtype: TextInputType.emailAddress,
                                      prefix: Icon(
                                        Icons.person,
                                        color: textColor,
                                      ),
                                      onsave: (email) {
                                        _formData['email'] = email ?? '';
                                      },
                                      validate: (email) {
                                        if (email!.isEmpty ||
                                            email.length < 3 ||
                                            !email.contains('@')) {
                                          return 'Enter correct email';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                    CustomTextField(
                                      hintText: 'Enter Password',
                                      isPassword: isPasswordHidden,
                                      prefix: Icon(
                                        Icons.vpn_key_rounded,
                                        color: textColor,
                                      ),
                                      onsave: (password) {
                                        _formData['password'] = password ?? '';
                                      },
                                      suffix: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isPasswordHidden =
                                                  !isPasswordHidden;
                                            });
                                          },
                                          icon: isPasswordHidden
                                              ? Icon(
                                                  Icons.visibility,
                                                  color: textColor,
                                                )
                                              : Icon(
                                                  Icons.visibility_off,
                                                  color: textColor,
                                                )),
                                      validate: (password) {
                                        if (password!.isEmpty ||
                                            password.length < 6) {
                                          return 'Enter correct password';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                    MainButton(
                                        title: 'Login',
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            _onSubmit();
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SubButton(
                                      title: 'New user? Sign up',
                                      onPressed: () => navigateToRegisterSelect(context)),
                                  SubButton(
                                      title: 'Forgot password',
                                      onPressed: () => navigateToForgotPassword(context)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
