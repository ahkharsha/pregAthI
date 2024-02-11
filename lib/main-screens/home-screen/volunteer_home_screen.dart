import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/home-screen/volunteer/volunteer_profile_screen.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/volunteer_history.dart';
import 'package:pregathi/user_permission.dart';
import 'package:url_launcher/url_launcher.dart';

class VolunteerHomeScreen extends StatefulWidget {
  VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
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

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('emergencies');

  _getAddressFromLaLo() async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placeMarks[0];
      setState(() {
        _volunteerLocality = place.locality;
        _volunteerPostal = place.postalCode;
        print('Updating in firestore');
        FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'locality': _volunteerLocality,
          'postal': _volunteerPostal,
        });
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  _getVolunteerLocation() async {
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
    goTo(context, VolunteerHomeScreen());
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

  @override
  void initState() {
    super.initState();
    _checkUpdate();
    _getVolunteerLocation();
    _getToken();
    initPermissions();
    updateLastLogin();
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
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(emergencyDetails['profilePic']),
                maxRadius: 150,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Mom in emergency!!!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 5,
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
          actions: [
            ElevatedButton(
              onPressed: () {
                _completeEmergency(emergencyDetails);
              },
              child: Text('Complete'),
            ),
            ElevatedButton(
              onPressed: () async {
                String googleUrl = '${emergencyDetails['location']}';

                /*if (Platform.isAndroid) {
                  if (await canLaunchUrl(Uri.parse(googleUrl))) {
                    await launchUrl(Uri.parse(googleUrl));
                  } else {
                    throw 'Could not launch $googleUrl';
                  }
                }*/

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
      return Text('${time}, Today - ${locality}, ${postal}');
    } else {
      return Text('${time}, ${date} - ${locality}, ${postal}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            goTo(context, VolunteerProfileScreen());
          },
          icon: Icon(Icons.person),
        ),
        title: Text(
          "pregAthI",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              UserSharedPreference.setUserRole('');
              goTo(context, LoginScreen());
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _reference.get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return dialogueBox(
                context, 'Some error has occurred ${snapshot.error}');
          }

          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;

            List<Map<String, dynamic>> items = documents
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

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> thisItem = items[index];
                print(_volunteerLocality);
                print(_volunteerPostal);

                if (_volunteerLocality == thisItem['locality'] ||
                    _volunteerPostal == thisItem['postal']) {
                      print('${thisItem['name']} lives in the same locality as the volunteer');
                  return GestureDetector(
                    onTap: () {
                      _showEmergencyAlertDialog(thisItem);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(thisItem['profilePic']),
                      ),
                      title: Text('${thisItem['name']}'),
                      subtitle: checkCurrentDate(
                          thisItem['time'],
                          thisItem['date'],
                          thisItem['locality'],
                          thisItem['postal']),
                    ),
                  );
                } else {
                  print('${thisItem['name']} does not live in the same locality as the volunteer');
                }

                // If the condition is not met, return an empty container
                return Container();
              },
            );
          }

          return progressIndicator(context);
        },
      ),
    );
  }
}
