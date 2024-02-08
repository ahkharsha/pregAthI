import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/main-screens/register_select_screen.dart';
import 'package:pregathi/model/volunteer_user.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/buttons/main_button.dart';
import 'package:pregathi/widgets/textfield.dart';

class VolunteerRegisterScreen extends StatefulWidget {
  @override
  State<VolunteerRegisterScreen> createState() =>
      _VolunteerRegisterScreenState();
}

class _VolunteerRegisterScreenState extends State<VolunteerRegisterScreen> {
  bool isPasswordHidden = true;
  bool isRePasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formKey.currentState!.save();

    if (_formData['password'] != _formData['re_password']) {
      dialogueBox(context, 'password and retype password must be same');
    } else {
      progressIndicator(context);
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _formData['volunteer_email'].toString(),
                password: _formData['password'].toString());
        if (userCredential.user != null) {
          final v = userCredential.user!.uid;
          DocumentReference<Map<String, dynamic>> db =
              FirebaseFirestore.instance.collection('users').doc(v);

          final user = VolunteerUserModel(
            name: _formData['name'].toString(),
            phone: _formData['phone'].toString(),
            volunteerEmail: _formData['volunteer_email'].toString(),
            id: v,
            role: 'volunteer',
            profilePic: volunteerProfileDefault,
            token:''
          );
          final jsonData = user.toJson();
          await db.set(jsonData).whenComplete(() {
            goTo(context, LoginScreen());
            setState(() {
              isLoading = false;
            });
            Future.delayed(const Duration(microseconds: 1),() {
              dialogueBox(context, 'Registration successful. Login to proceed');
              });
          });
        }
      }
      //on FirebaseAuthException catch (e) {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   if (e.code == 'weak-password') {
      //     dialogueBox(context, 'The password provided is too weak.');
      //   } else if (e.code == 'email-already-in-use') {
      //     dialogueBox(context, 'The account already exists for that email.');
      //   }
      // }
      catch (e) {
        setState(() {
          isLoading = false;
        });
        dialogueBox(
            context, e.toString());
      }
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
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Volunteer Register',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/login/volunteer.png',
                                  height: 100,
                                  width: 100,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.66,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomTextField(
                                    hintText: 'Enter name',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.name,
                                    prefix: Icon(Icons.person),
                                    onsave: (name) {
                                      _formData['name'] = name ?? '';
                                    },
                                    // validate: (name) {
                                    //   if (name!.isEmpty || name.length < 2) {
                                    //     return 'Name should contain atleast 2 characters';
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                  ),
                                  CustomTextField(
                                    hintText: 'Enter phone',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.phone,
                                    prefix: Icon(Icons.phone),
                                    onsave: (phone) {
                                      _formData['phone'] = phone ?? '';
                                    },
                                    // validate: (phone) {
                                    //   if (phone!.isEmpty || phone.length < 10) {
                                    //     return 'Phone number should contain 10 digits';
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                  ),
                                  CustomTextField(
                                    hintText: 'Enter email',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.emailAddress,
                                    prefix: Icon(Icons.alternate_email_rounded),
                                    onsave: (volunteer_email) {
                                      _formData['volunteer_email'] = volunteer_email ?? '';
                                    },
                                    // validate: (volunteer_email) {
                                    //   if (volunteer_email!.isEmpty ||
                                    //       volunteer_email.length < 3 ||
                                    //       !volunteer_email.contains('@')) {
                                    //     return 'Enter correct email';
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                  ),
                                  CustomTextField(
                                    hintText: 'Enter password',
                                    isPassword: isPasswordHidden,
                                    prefix: Icon(Icons.vpn_key_rounded),
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
                                            ? Icon(Icons.visibility)
                                            : Icon(Icons.visibility_off)),
                                    // validate: (password) {
                                    //   if (password!.isEmpty || password.length < 6) {
                                    //     return 'Enter correct password';
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                  ),
                                  CustomTextField(
                                    hintText: 'Retype password',
                                    isPassword: isRePasswordHidden,
                                    prefix: Icon(Icons.vpn_key_rounded),
                                    onsave: (re_password) {
                                      _formData['re_password'] =
                                          re_password ?? '';
                                    },
                                    suffix: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isRePasswordHidden =
                                                !isRePasswordHidden;
                                          });
                                        },
                                        icon: isRePasswordHidden
                                            ? Icon(Icons.visibility)
                                            : Icon(Icons.visibility_off)),
                                    // validate: (re_password) {
                                    //   if (re_password!.isEmpty ||
                                    //       re_password.length < 6) {
                                    //     return 'Retype correct password';
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                  ),
                                  MainButton(
                                      title: 'Register',
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
                                Container(
                                  child: SubButton(
                                      title: 'Already have an account? Login',
                                      onPressed: () {
                                        goTo(context, LoginScreen());
                                      }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: SubButton(
                                      title: 'Back to User select',
                                      onPressed: () {
                                        goTo(context, RegisterSelectScreen());
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
