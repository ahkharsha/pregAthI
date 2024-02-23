import 'dart:math';

import 'package:basics/basics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/community-chat/community_home.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/drawers/wife/profile_drawer.dart';
import 'package:pregathi/main-screens/drawers/wife/options_drawer.dart';
import 'package:pregathi/main.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/user_permission.dart';
import 'package:pregathi/widgets/home/ai-chat/ai_chat.dart';
import 'package:pregathi/widgets/home/bottom-bar/calendar_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/contacts_screen.dart';
import 'package:pregathi/widgets/home/emergency.dart';
import 'package:pregathi/widgets/home/services.dart';
import 'package:pregathi/widgets/home/insta_share/insta_share.dart';
import 'package:pregathi/widgets/home/wife-drawer/news_screen.dart';
import 'package:pregathi/widgets/home/wife-drawer/work_from_home.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pregathi/multi-language/classes/language.dart';

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

  @override
  void initState() {
    super.initState();
    _checkUpdate();
    _getProfilePic();
    _getCurrentLocation();
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
            title: Text(
              'A newer version of the app is available. Please download to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp),
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

  _getProfilePic() async {
    final User? user = FirebaseAuth.instance.currentUser;
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    DocumentSnapshot userData = await _reference.get();

    setState(() {
      profilePic = userData['profilePic'];
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

  int showOptionsDrawer = 0;
  int showProfileDrawer = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            boxColor,
          ],
          end: Alignment.topCenter,
          begin: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                  
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                    
                      'Features',
                      style: TextStyle(fontSize: 20,),
                    ),
                    
                  ),
                  Divider(
                    height: 3,
                    color: Colors.black,
                    indent: 3.w,
                    endIndent: 3.w,
                  ),
                  ListTile(
                    title: Text("Community"),
                    leading: Icon(Icons.groups_2_rounded),
                    onTap: () {
                      goTo(context, CommunityHome());
                    },
                  ),
                  ListTile(
                    title: Text("AI Chat"),
                    leading: Icon(Icons.mark_unread_chat_alt_rounded),
                    onTap: () {
                      goTo(context, ChatScreen());
                    },
                  ),
                  ListTile(
                    title: Text("Contacts"),
                    leading: Icon(Icons.contacts),
                    onTap: () {
                      goTo(context, ContactsScreen());
                    },
                  ),
                  ListTile(
                    title: Text("Calender"),
                    leading: Icon(Icons.calendar_month_rounded),
                    onTap: () {
                      goTo(context, CalendarScreen());
                    },
                  ),
                  ListTile(
                    title: Text("Work from Home"),
                    leading: Icon(Icons.work_rounded),
                    onTap: () {
                      goTo(context, WorkFromHomeScreen());
                    },
                  ),
                  ListTile(
                    title: Text("Preg News"),
                    leading: Icon(Icons.newspaper_outlined),
                    onTap: () {
                      goTo(context, NewsScreen());
                    },
                  ),
                  ListTile(
                    title: Text("Close"),
                    leading: Icon(Icons.close_outlined),
                    onTap: () {
                      setState(() {
                        showOptionsDrawer = 0;
                        
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: showOptionsDrawer == 1 ? 1 : 0),
            duration: Duration(milliseconds: 300),
            builder: (_, double v, __) {
              return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..setEntry(0, 3, 200 * v)
                    ..rotateY(
                      (pi / 6) * v,
                    ),
                  child: ClipRRect(
                    borderRadius: showOptionsDrawer == 1
                        ? BorderRadius.circular(10.0)
                        : BorderRadius.circular(0),
                    child: Scaffold(
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
                            onPressed: () {
                              setState(() {
                                showOptionsDrawer = 1;
                              });
                            },
                            icon: Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                            ),
                          );
                        }),


                        
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
                                  Locale _locale =
                                      await setLocale(language.languageCode);
                                  MyApp.setLocale(context, _locale);
                                }
                              },
                              items: Language.languageList()
                                  .map<DropdownMenuItem<Language>>(
                                    (e) => DropdownMenuItem<Language>(
                                      value: e,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text(
                                            e.flag,
                                            style: TextStyle(fontSize: 25.sp),
                                          ),
                                          Text(e.name)
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.045),
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
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8, left: 15),
                                    child: Text(
                                      translation(context).emergency,
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Emergency(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8, left: 15),
                                    child: Text(
                                      translation(context).services,
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Services(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8, left: 15),
                                    child: Text(
                                      translation(context).instaShare,
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const InstaShare(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8, left: 15),
                                    child: Text(
                                      translation(context).aiChat,
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const AIChat(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ));
            },
          ),
          GestureDetector(
            onHorizontalDragUpdate: (value) {
              if (value.delta.dx > 0) {
                setState(() {
                  showOptionsDrawer = 1;
                });
              } else {
                setState(() {
                  showOptionsDrawer = 0;
                });
              }
            },
          )
        ],
      ),
    );
  }
}