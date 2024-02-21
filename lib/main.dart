import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pregathi/db/shared_pref.dart';

import 'package:pregathi/main-screens/home-screen/volunteer_home_screen.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'multi-language/classes/language_constants.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  await UserSharedPreference.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) => setLocale(locale));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'pregAthI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.firaSansTextTheme(
              Theme.of(context).textTheme,
            ),
            primarySwatch: Colors.blue,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _locale,
          home: FutureBuilder(
            future: UserSharedPreference.getUserRole(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == '') {
                return LoginScreen();
              } else if (snapshot.data == 'wife') {
                return BottomPage();
              } else if (snapshot.data == 'volunteer') {
                return VolunteerHomeScreen();
              } 
              return progressIndicator(context);
            },
          ),
        );
      },
    );
  }
}
