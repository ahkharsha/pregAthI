import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class VolunteerHomeScreen extends StatefulWidget {
  VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  String? _volunteerLocality;
  String? _volunteerPostal;
  Position? _currentPosition;
  LocationPermission? permission;
  late DocumentReference _documentReference;

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('emergencies');

  _getPermission() async => await [Permission.location].request();

  _getAddressFromLaLo() async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placeMarks[0];
      setState(() {
        _volunteerLocality = place.locality;
        _volunteerPostal = place.postalCode;
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
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference<Map<String, dynamic>> db =
          FirebaseFirestore.instance.collection(user.uid).doc(emergency['id']);

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

  @override
  void initState() {
    super.initState();
    _getPermission();
    _getVolunteerLocation();
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
                maxRadius: 100,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Mom in emergency!!!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Text(
                'Name: ${emergencyDetails['name']}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                'Phone: ${emergencyDetails['phone']}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                'Time: ${emergencyDetails['time']} @ ${emergencyDetails['locality']}, ${emergencyDetails['postal']}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                ),
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
