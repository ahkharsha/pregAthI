import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/home-screen/husband_home_screen.dart';
import 'package:pregathi/main-screens/home-screen/volunteer/temp.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final String currentVersion = "1.0.0";

  _checkUpdate() async {
    DocumentSnapshot versionDetails = await FirebaseFirestore.instance
        .collection('pregAthI')
        .doc('version')
        .get();

    if (currentVersion != versionDetails['latestVersion']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          child: AlertDialog(
            title: Text(
              'A newer version of the app is available. Please download to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  String googleUrl =
                      'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

                  final Uri _url = Uri.parse(googleUrl);
                  try {
                    await launchUrl(_url);
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'Error');
                  }
                },
                child: Text('Download'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
        ),
      );
    } else {
      Scaffold(
        body: FutureBuilder(
          future: UserSharedPreference.getUserRole(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == '') {
              goToDisableBack(context, LoginScreen());
            } else if (snapshot.data == 'wife') {
              goToDisableBack(context, BottomPage());
            } else if (snapshot.data == 'volunteer') {
              goToDisableBack(context, VolunteerHomeScreen());
            } else if (snapshot.data == 'husband') {
              goToDisableBack(context, HusbandHomeScreen());
            }
            return progressIndicator(context);
          },
        ),
      );
    }
  }

  @override
  void initState() {
    _checkUpdate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
