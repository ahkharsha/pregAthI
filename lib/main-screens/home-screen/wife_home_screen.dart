import 'package:basics/basics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/user_permission.dart';
import 'package:pregathi/widgets/home/ai-chat/ai_chat.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_screen.dart';
import 'package:pregathi/widgets/home/emergency.dart';
import 'package:pregathi/widgets/home/services.dart';
import 'package:pregathi/widgets/home/insta_share/insta_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pregathi/multi-language/classes/language.dart';

class WifeHomeScreen extends ConsumerStatefulWidget {
  const WifeHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WifeHomeScreenState();
}

class _WifeHomeScreenState extends ConsumerState<WifeHomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final String currentVersion = "1.0.0";
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
    _getCurrentLocation();
    initPermissions();
    updateLastLogin();
    updatedWifeWeek();
  }

  //Remove this function to cancel checkUpdates everytime wife home screen is opened
  _checkUpdate() async {
    print('The uid of the current user is');
    print(user!.uid);
    DocumentSnapshot versionDetails = await FirebaseFirestore.instance
        .collection('pregAthI')
        .doc('version')
        .get();

    if (currentVersion != versionDetails['latestVersion']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
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
                child: const Text('Download'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
        ),
      );
    }
  }

  updateLastLogin() {
    DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd/MM/yy').format(now);
    var formatterTime = DateFormat('kk:mm').format(now);
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'lastLogin': '${formatterTime}, ${formatterDate}',
    });
  }

  initPermissions() async {
    await UserPermission().initSmsPermission();
    await UserPermission().initContactsPermission();
    await UserPermission().initLocationPermission();
  }

  updatedWifeWeek() async {
    DateTime now = DateTime.now();
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    var current_year = now.year;
    var current_mon = now.month;
    var current_day = now.day;
    DocumentSnapshot userData = await _reference.get();
    // ignore: unused_local_variable
    int diffWeek = 0;
    int week = int.tryParse(userData['weekUpdated'] ?? '') ?? 0;

    int diffDays = DateTime(userData['weekUpdatedYear'],
            userData['weekUpdatedMonth'], userData['weekUpdatedDay'])
        .calendarDaysTill(current_year, current_mon, current_day);

    if (diffDays > 7) {
      while (diffDays >= 7) {
        diffWeek += 1;
        diffDays -= 7;
      }

      week += diffWeek;

      _reference.update({
        'week': week.toString(),
      });
    }
  }

  _getCurrentLocation() async {
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true,
    ).then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLaLo();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLaLo() async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placeMarks[0];
      setState(() {
        _currentAddress =
            "${place.locality},${place.postalCode},${place.street},${place.name},${place.subLocality}";
        FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'currentAddress': _currentAddress,
          'currentLatitude': _currentPosition!.latitude.toString(),
          'currentLongitude': _currentPosition!.longitude.toString(),
        });
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translation(context).pregAthI,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 25,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            goTo(context, const ProfileScreen());
          },
          icon: const Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<Language>(
              underline: const SizedBox(),
              icon: const Icon(
                Icons.language,
                color: Colors.white,
              ),
              onChanged: (Language? language) async {
                if (language != null) {
                  Locale _locale = await setLocale(language.languageCode);
                  MyApp.setLocale(context, _locale);
                }
              },
              items: Language.languageList()
                  .map<DropdownMenuItem<Language>>(
                    (e) => DropdownMenuItem<Language>(
                      value: e,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            e.flag,
                            style: const TextStyle(fontSize: 30),
                          ),
                          Text(e.name)
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).emergency,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Emergency(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).services,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Services(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).instaShare,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const InstaShare(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).aiChat,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const AIChat(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
