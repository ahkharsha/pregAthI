import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pregathi/const/loader.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/home-screen/volunteer/volunteer_profile_screen.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/volunteer_history.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class VolunteerHomeScreen extends StatefulWidget {
  VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final String currentVersion = '1.0.0';
  String? myToken;
  final User? user = FirebaseAuth.instance.currentUser;

  String? _volunteerLocality;
  String? _volunteerPostal;
  Position? _currentPosition;
  LocationPermission? permission;
  late DocumentReference _documentReference;

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('emergencies');

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

  _getPermission() async => await [Permission.location].request();

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
          'locality':_volunteerLocality,
          'postal':_volunteerPostal,
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
      DocumentReference<Map<String, dynamic>> db =
          FirebaseFirestore.instance.collection(user!.uid).doc(emergency['id']);

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
    FirebaseMessaging messaging=FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus==AuthorizationStatus.denied) {
      Fluttertoast.showToast(msg: 'Permission denied');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAA9xPglTQ:APA91bEuI1Hg2Mw6dLpBuh2bDvJfgcYOUm_rEUhq3glaPRzICYtTUQEG6iFF1r_EeWx3B_wC9sTDVxk0x1PYgcSh-N9Di4qG-GNF3LVDjhc9F5B_cfEqvdky-Rc1ILwdAc1oqtB5Ho8v',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

   void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _checkUpdate();
    _getPermission();
    _getVolunteerLocation();
    _getToken();
    requestPermission();
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
                  return GestureDetector(
                    onTap: () {
                      _showEmergencyAlertDialog(thisItem);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(thisItem['profilePic']),
                      ),
                      title: Text('${thisItem['name']}'),
                      subtitle: Text(
                          '${thisItem['time']} - ${thisItem['locality']}, ${thisItem['postal']}'),
                    ),
                  );
                }

                // If the condition is not met, return an empty container
                return Container();
              },
            );
          }

          return Loader();
        },
      ),
    );
  }
}
