import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/main-screens/drawers/wife/volunteer/volunteer_profile_drawer.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/volunteer_history.dart';
import 'package:pregathi/navigators.dart';
import 'package:pregathi/user_permission.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class VolunteerHomeScreen extends StatefulWidget {
  VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  Key streamBuilderKey = UniqueKey();
  String? profilePic = volunteerProfileDefault;
  bool forceReload = false;
  int localEmergency = 0;

  final String currentVersion = '1.0.0';
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
    }
  }

  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String? myToken;
  final User? user = FirebaseAuth.instance.currentUser;

  String? _volunteerLocality;
  String? _volunteerPostal;
  Position? _currentPosition;
  LocationPermission? permission;
  late DocumentReference _documentReference;
  Timer? timer;

  void openProfileDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  void initState() {
    super.initState();
    setVolunteerLocation();
    _checkUpdate();
    _getToken();
    _getProfilePic();
    _updateVolunteerLocation();
    _checkLatestAnnoucement();
    initPermissions();
    updateLastLogin();
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
                onPressed: () => navigateToAnnouncement(context),
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
      Navigator.of(context).pop();
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

  _updateVolunteerLocation() async {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition!.latitude);
        _getAddressFromLaLo();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLaLo() async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placeMarks[0];
      setState(() {
        print('Updating in firestore');
        FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'locality': place.locality,
          'postal': place.postalCode,
        });
        _volunteerLocality = place.locality;
        _volunteerPostal = place.postalCode;

        streamBuilderKey = UniqueKey();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  setVolunteerLocation() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((volunteerLocation) {
      setState(() {
        _volunteerLocality = volunteerLocation['locality'];
        _volunteerPostal = volunteerLocation['postal'];
        print('Set location successfully');
      });
    });
  }

  _completeEmergency(Map<String, dynamic> emergency) async {
    if (user != null) {
      DocumentReference<Map<String, dynamic>> db = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('past-services')
          .doc(emergency['id']);

      final data = VolunteerHistory(
          name: emergency['name'],
          id: emergency['id'],
          phone: emergency['phone'],
          wifeEmail: emergency['wifeEmail'],
          location: emergency['location'],
          date: emergency['date'],
          time: emergency['time'],
          locality: emergency['locality'],
          postal: emergency['postal'],
          profilePic: emergency['profilePic']);

      final jsonData = data.toJson();
      db.set(jsonData);
    }
    _documentReference = FirebaseFirestore.instance
        .collection('emergencies')
        .doc(emergency['id']);

    _documentReference.delete();
    navigateToVolunteerHome(context);
  }

  _getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        myToken = token;
      });

      saveToken(token!);
    });
  }

  saveToken(String token) async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'token': token,
    });
  }

  requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      Fluttertoast.showToast(msg: 'Permission denied');
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
    await UserPermission().initNotificationsPermission();
    await UserPermission().initLocationPermission();
  }

  void _showEmergencyAlertDialog(Map<String, dynamic> emergencyDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Emergency Alert',
            style: TextStyle(
              color: Colors.red,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(emergencyDetails['profilePic']),
                  maxRadius: 150,
                ),
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  'Mom in emergency!!!',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  'Name: ${emergencyDetails['name']}',
                ),
                Text(
                  'Phone: ${emergencyDetails['phone']}',
                ),
                Text(
                  'Time: ${emergencyDetails['time']} @ ${emergencyDetails['locality']}, ${emergencyDetails['postal']}',
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _completeEmergency(emergencyDetails);
              },
              child: Text('Complete'),
            ),
            ElevatedButton(
              onPressed: () async {
                print(forceReload);
                String googleUrl = '${emergencyDetails['location']}';

                final Uri _url = Uri.parse(googleUrl);
                try {
                  await launchUrl(_url);
                } catch (e) {
                  Fluttertoast.showToast(msg: 'Error');
                }
              },
              child: Text('Maps'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  void _showFixedEmergencyAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Emergency Alert',
            style: TextStyle(
              color: Colors.red,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://firebasestorage.googleapis.com/v0/b/pregathi-69.appspot.com/o/profile%2Fd5b0dd9a-3b84-4c99-aef2-0a6369f54580?alt=media&token=43b530c7-fa1b-44b8-80f9-c8f38e140ad3'),
                  maxRadius: 150,
                ),
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  'Mom in emergency!!!',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  'This is a fixed sample emergency. Actual emergencies from your locality/pin code will appear on your home screen as and when they are initiated',
                ),
                Text(
                  'Name: Varshini',
                ),
                Text(
                  'Phone: xxxxxxxxxx',
                ),
                Text(
                  'Time: 14:29 @ Avadi, 600072',
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(
                    msg:
                        'This emergency is fixed for demo. It cannot be completed by you.');
                goBack(context);
              },
              child: Text('Complete'),
            ),
            ElevatedButton(
              onPressed: () async {
                print(forceReload);
                String googleUrl =
                    'https://www.google.com/maps/search/?api=1&query=13.1207482%2C80.078119';

                final Uri _url = Uri.parse(googleUrl);
                try {
                  await launchUrl(_url);
                } catch (e) {
                  Fluttertoast.showToast(msg: 'Error');
                }
              },
              child: Text('Maps'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  checkCurrentDate(String time, String date, String locality, String postal) {
    DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd/MM/yy').format(now);
    if (formatterDate == date) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${locality}, ${postal}',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          Text(
            '${time}, Today',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${locality}, ${postal}',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          Text(
            '${time}, ${date}',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "pregAthI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.045),
                child: GestureDetector(
                  onTap: () => openProfileDrawer(context),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 15.5,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profilePic!),
                      radius: 15,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      endDrawer: VolunteerProfileDrawer(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              forceReload = true;
            });
          },
          backgroundColor: boxColor,
          foregroundColor: textColor,
          shape: CircleBorder(),
          highlightElevation: 50,
          child: Icon(
            Icons.refresh_outlined,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 8,
              left: 15,
              right: 15,
            ),
            child: Text(
              'Current emergencies',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showFixedEmergencyAlertDialog();
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 10, top: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: boxColor,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                        'https://firebasestorage.googleapis.com/v0/b/pregathi-69.appspot.com/o/profile%2Fd5b0dd9a-3b84-4c99-aef2-0a6369f54580?alt=media&token=43b530c7-fa1b-44b8-80f9-c8f38e140ad3'),
                  ),
                  title: Text(
                    'Varshini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '(This is a fixed sample emergency)',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Avadi, 600072',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '14:29, 21/02/24',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('emergencies')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return dialogueBox(
                    context, 'Some error has occurred ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return progressIndicator(context);
              }

              List<Map<String, dynamic>> items = snapshot.data!.docs
                  .map(
                    (emergency) => {
                      'id': emergency['id'],
                      'name': emergency['name'],
                      'location': emergency['location'],
                      'date': emergency['date'],
                      'phone': emergency['phone'],
                      'time': emergency['time'],
                      'wifeEmail': emergency['wifeEmail'],
                      'locality': emergency['locality'],
                      'postal': emergency['postal'],
                      'profilePic': emergency['profilePic']
                    },
                  )
                  .toList();

              return Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> thisItem = items[index];

                    print('the length of the items is');
                    print(items.length);
                    print('the location is $_volunteerLocality');
                    print('the pin code is $_volunteerPostal');

                    if (_volunteerLocality == thisItem['locality'] ||
                        _volunteerPostal == thisItem['postal']) {
                      localEmergency++;
                      print('Increased local emergency by 1');
                      print(
                          '${thisItem['name']} lives in the same locality as the volunteer');
                      return GestureDetector(
                        onTap: () {
                          _showEmergencyAlertDialog(thisItem);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 10, top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: boxColor,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 35,
                                backgroundImage:
                                    NetworkImage(thisItem['profilePic']),
                              ),
                              title: Text(
                                '${thisItem['name']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: checkCurrentDate(
                                  thisItem['time'],
                                  thisItem['date'],
                                  thisItem['locality'],
                                  thisItem['postal']),
                            ),
                          ),
                        ),
                      );
                    } else {
                      print(
                          '${thisItem['name']} does not live in the same locality as the volunteer');
                    }

                    return Container();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
