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
  // ignore: unused_field
  String? _volunteerPostal;
  Position? _currentPosition;
  LocationPermission? permission;

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
        _volunteerPostal=place.postalCode;
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
                context, 'Some error has occured ${snapshot.error}');
          }

          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;

            List<Map> items = documents
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
                Map thisItem = items[index];
                print(_volunteerLocality);
                print(_volunteerPostal);
                if (_volunteerLocality == thisItem['locality'] || _volunteerPostal==thisItem['postal']) {
                  return ListTile(
                    title: Text('${thisItem['name']}'),
                    subtitle: Text('${thisItem['time']} - ${thisItem['locality']}, ${thisItem['postal']}'),
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

// Center(
//         child: Padding(
//           padding: EdgeInsets.only(bottom: 20),
//           child: ElevatedButton(
//             onPressed: () {
//               UserSharedPreference.setUserRole('');
//               goTo(context, LoginScreen());
//             },
//             child: Padding(
//               padding: EdgeInsets.all(0),
//               child: Text(
//                 "Logout from Volunteer homescreen",
//                 style: TextStyle(
//                   fontSize: 18,
//                   //fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ),
//       ),
