import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pregathi/const/loader.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/const/constants.dart';

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
          title: Text('Emergency Alert'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${emergencyDetails['name']}'),
              Text('${emergencyDetails['phone']}'),
              Text(
                  '${emergencyDetails['time']} - ${emergencyDetails['locality']}, ${emergencyDetails['postal']}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Add logic to open Maps here
              },
              child: Text('Maps'),
            ),
            ElevatedButton(
              onPressed: () {
                print(emergencyDetails['id']);
                _documentReference =
                    FirebaseFirestore.instance
                        .collection('emergencies')
                        .doc(emergencyDetails['id']);

                        _documentReference.delete();
                        goTo(context, VolunteerHomeScreen());
              },
              child: Text('Delete'),
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
            UserSharedPreference.setUserRole('');
            goTo(context, LoginScreen());
          },
          icon: Icon(Icons.logout),
        ),
        title: Text(
          "pregAthI",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
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
                      title: Text('${thisItem['name']}'),
                      subtitle: Text(
                          '${thisItem['time']} - ${thisItem['locality']}, ${thisItem['postal']}'),
                    ),
                  );
                }
                return null;
              },
            );
          }

          return Loader();
        },
      ),
    );
  }
}
