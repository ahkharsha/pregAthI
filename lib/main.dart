import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/home-screen/husband_home_screen.dart';
import 'package:pregathi/main-screens/home-screen/volunteer_home_screen.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UserSharedPreference.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pregAthI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.firaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: UserSharedPreference.getUserRole(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == '') {
            return LoginScreen();
          }
          else if (snapshot.data == 'wife') {
            return BottomPage();
          }
          else if (snapshot.data == 'volunteer') {
            return VolunteerHomeScreen();
          }
          else if (snapshot.data == 'husband') {
            return HusbandHomeScreen();
          }
          return progressIndicator(context);
        },
      ),
    );
  }
}
