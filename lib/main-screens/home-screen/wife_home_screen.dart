import 'dart:async';

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
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/announcements.dart';
import 'package:pregathi/main-screens/drawers/wife/profile_drawer.dart';
import 'package:pregathi/main-screens/drawers/wife/options_drawer.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/user_permission.dart';
import 'package:pregathi/widgets/home/ai-chat/ai_chat.dart';
import 'package:pregathi/widgets/home/emergency.dart';
import 'package:pregathi/widgets/home/services.dart';
import 'package:pregathi/widgets/home/insta_share/insta_share.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class WifeHomeScreen extends ConsumerStatefulWidget {
  const WifeHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WifeHomeScreenState();
}

class _WifeHomeScreenState extends ConsumerState<WifeHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? user = FirebaseAuth.instance.currentUser;
  final String currentVersion = "1.0.0";
  Position? _currentPosition;
  String? _currentAddress;
  String? profilePic = wifeProfileDefault;
  bool? isBanned = false;
  String? lastAnnoucement;
  Timer? timer;
  String? username = '';

  @override
  void initState() {
    super.initState();
    _checkUpdate();
    _checkBan();
    _getProfilePic();
    _getCurrentLocation();
    _checkLatestAnnoucement();
    _updateUserVersion();
    initPermissions();
    updateLastLogin();
    updatedWifeWeek();
  }

  void openOptionsDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void openProfileDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  _updateUserVersion() {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'userVersion': currentVersion,
    });
  }

  _checkLatestAnnoucement() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    DocumentSnapshot announcement = await FirebaseFirestore.instance
        .collection('pregAthI')
        .doc('version')
        .get();

    print('The current and the latest announcements are respectively');
    print(userData['lastAnnouncement']);
    print(announcement['latestAnnouncement']);

    if (userData['lastAnnouncement'] != announcement['latestAnnouncement']) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(
              'You have new unread announcements!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  goTo(context, AnnouncementScreen());
                },
                child: const Text('View'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
        ),
      );
      timer = Timer.periodic(
        Duration(seconds: 1),
        (_) => checkReadAnnouncement(),
      );
    }
  }

  Future checkReadAnnouncement() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    DocumentSnapshot announcement = await FirebaseFirestore.instance
        .collection('pregAthI')
        .doc('version')
        .get();

    if (userData['lastAnnouncement'] == announcement['latestAnnouncement']) {
      timer?.cancel();
      goBack(context);
    }
  }

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
          canPop: false,
          child: AlertDialog(
            title: Text(
              'A newer version of the app is available. Please download to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  String googleUrl = 'https://pregathi-e856c9.webflow.io/';

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

  _checkBan() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (userData['isBanned']) {
      DateTime now = DateTime.now();
      var current_year = now.year;
      var current_mon = now.month;
      var current_day = now.day;

      int diffDays = DateTime(userData['lastBanYear'], userData['lastBanMonth'],
              userData['lastBanDay'])
          .calendarDaysTill(current_year, current_mon, current_day);

      if (diffDays < 7) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(
                'Your account was banned for 7 days due to receiving multiple account strikes. Please wait ${7 - diffDays} days before continuing to use your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    goToDisableBack(context, LoginScreen());
                    await FirebaseAuth.instance.signOut();
                    UserSharedPreference.setUserRole('');
                  },
                  child: const Text('Ok'),
                ),
              ],
              actionsAlignment: MainAxisAlignment.center,
            ),
          ),
        );
      } else {
        FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'isBanned': false,
        });
      }
    }
  }

  _getProfilePic() async {
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    DocumentSnapshot userData = await _reference.get();

    setState(() {
      profilePic = userData['profilePic'];
      username = userData['name'];
    });
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
    if (userData['weekUpdated'] != 'new') {
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
      print(e.toString());
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
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          translation(context).pregAthI,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => openOptionsDrawer(context),
            icon: Icon(
              Icons.menu_rounded,
              color: Colors.white,
            ),
          );
        }),
        actions: [
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.045),
            child: GestureDetector(
              onTap: openProfileDrawer,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15.5,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profilePic!),
                  radius: 15,
                ),
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      drawer: WifeOptionsDrawer(),
      endDrawer: WifeProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 16, bottom: 1, left: 15),
                      child: Row(
                        children: [
                          Text(
                            'Hello ',
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'BebasNeue',
                            ),
                          ),
                          Text(
                            '$username',
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BebasNeue',
                            ),
                          ),
                          Text(
                            ',',
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'BebasNeue',
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8, left: 15),
                    child: Text(
                      translation(context).emergency,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Emergency(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).services,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Services(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).instaShare,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const InstaShare(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).aiChat,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
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
