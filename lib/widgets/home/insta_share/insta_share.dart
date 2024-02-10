import 'package:background_sms/background_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pregathi/buttons/main_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/contacts.dart';
import 'package:pregathi/db/db_services.dart';
import 'package:pregathi/model/emergency_message.dart';
import 'package:pregathi/widgets/home/insta_share/wife_emergency_alert.dart';

class InstaShare extends StatefulWidget {
  const InstaShare({super.key});

  @override
  State<InstaShare> createState() => _InstaShareState();
}

class _InstaShareState extends State<InstaShare> {
  final User? user = FirebaseAuth.instance.currentUser;

  Position? _currentPosition;
  String? _curentAddress;
  late String husbandPhoneNumber;
  late String hospitalPhoneNumber;

  isPermissionGranted() async => Permission.sms.status.isGranted;

  sendSMSwithAlert(String phoneNumber, String message, {int? simSlot}) async {
    await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
    ).then((SmsStatus status) {
      if (status == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Sent");
      } else {
        Fluttertoast.showToast(msg: "Oops! Failed to send");
      }
    });
  }

  sendSMS(String phoneNumber, String message, {int? simSlot}) async {
    await BackgroundSms.sendMessage(
            phoneNumber: phoneNumber, message: message, simSlot: simSlot)
        .then((SmsStatus status) {
      if (status == "sent") {
        Fluttertoast.showToast(msg: "Sent");
      }
      // else {
      //   Fluttertoast.showToast(msg: "Oops! Failed to send");
      // }
    });
  }

  setFirebaseEmergency(String currentLocation) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      DocumentReference<Map<String, dynamic>> db =
          FirebaseFirestore.instance.collection('emergencies').doc(user.uid);

      List<Placemark> placeMarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placeMarks[0];

      DateTime now = DateTime.now();
      var formatterDate = DateFormat('dd/MM/yy').format(now);
      var formatterTime = DateFormat('kk:mm').format(now);
      final userMessage = EmergencyMessageModel(
          name: userData['name'],
          id: user.uid,
          phone: userData['phone'],
          wifeEmail: userData['wifeEmail'],
          location: currentLocation,
          date: formatterDate,
          time: formatterTime,
          locality: place.locality,
          postal: place.postalCode,
          profilePic: userData['profilePic']);

      final jsonData = userMessage.toJson();
      db.set(jsonData);
    }
  }

  _getCurrentLocation() async {
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
      print(e.toString());
    });
  }

  _getAddressFromLaLo() async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placeMarks[0];
      setState(() {
        _curentAddress =
            "${place.locality},${place.postalCode},${place.street},${place.name},${place.subLocality}";
        FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'locality': place.locality,
          'postal': place.postalCode,
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        husbandPhoneNumber = userData['husbandPhone'];
        hospitalPhoneNumber = userData['hospitalPhone'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    loadData();
  }

  showModelInstaShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Send current location immediately to emergency contacts..",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 10,
                ),
                if (_currentPosition != null)
                  Text(
                    _curentAddress!,
                    textAlign: TextAlign.center,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: MainButton(
                    title: "Send Alert",
                    onPressed: () async {
                      List<TContact> contactList =
                          await DatabaseService().getContactList();

                      if (_currentPosition != null) {
                        String msgBody =
                            "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_curentAddress";
                        String firebaseMsg =
                            "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}";

                        setFirebaseEmergency(firebaseMsg);

                        if (await isPermissionGranted()) {
                          for (TContact contact in contactList) {
                            sendSMS(
                              contact.number,
                              "Having inconvenience, so please reach out at $msgBody",
                            );
                          }
                          sendSMS(
                            husbandPhoneNumber,
                            "Having inconvenience, so reach please out at $msgBody",
                          );
                          sendSMSwithAlert(
                            hospitalPhoneNumber,
                            "Having inconvenience, so reach please out at $msgBody",
                          );
                        }

                        goTo(context, WifeEmergencyScreen());

                        // else {
                        //   Fluttertoast.showToast(msg: "Something is wrong..");
                        // }
                      }
                      // else {
                      //   Fluttertoast.showToast(msg: "Location not available..");
                      // }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelInstaShare(context),
      child: Padding(
        padding: const EdgeInsets.only(left: 14.0, right: 14.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height*0.25,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 208, 9, 248),
                  Color.fromARGB(255, 226, 98, 252),
                  Color.fromARGB(255, 237, 189, 248),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(
                                    top: 6.0, bottom: 14.0),
                                child: Text(
                                  "Send Location",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.06),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Text(
                                  "Click to share your current location..",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.045),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/images/insta-share/route.jpg',
                          height: 120,
                          width: 110,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
                  Center(
                    child: Container(
                      height: 30,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: Color.fromARGB(255, 208, 9, 248),
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
