import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/buttons/main_button.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/widgets/textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

  Future resetPassword() async {
    _formKey.currentState!.save();
    print(translation(context).theEmailentered);
    print(_formData['email'].toString());
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _formData['email'].toString());
      goToDisableBack(context, LoginScreen());

      Future.delayed(const Duration(microseconds: 1), () {
        dialogueBoxWithButton(context,
            'The password reset link has been sent sucessfully if an account with that email exists!');
      });
    } on FirebaseAuthException catch (e) {
      dialogueBox(context, e.toString());
    } catch (e) {
      dialogueBox(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    translation(context).resetPassword,
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/login/forgot_pwd.png',
                                    height: 100,
                                    width: 100,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.32,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomTextField(
                                      hintText: translation(context).enterEmail,
                                      textInputAction: TextInputAction.next,
                                      keyboardtype: TextInputType.emailAddress,
                                      prefix:
                                          Icon(Icons.alternate_email_rounded),
                                      onsave: (email) {
                                        _formData['email'] = email ?? '';
                                      },
                                      // validate: (email) {
                                      //   if (email!.isEmpty ||
                                      //       email.length < 3 ||
                                      //       !email.contains('@')) {
                                      //     return 'Enter correct email';
                                      //   } else {
                                      //     return null;
                                      //   }
                                      // },
                                    ),
                                    MainButton(
                                        title: translation(context).resetPassword,
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            resetPassword();
                                          }
                                        }),
                                    SubButton(
                                        title: 'Back to Login',
                                        onPressed: () {
                                          goToDisableBack(
                                              context, LoginScreen());
                                        }),
                                  ],
                                ),
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
