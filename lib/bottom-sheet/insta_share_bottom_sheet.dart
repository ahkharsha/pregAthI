import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pregathi/buttons/main_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/db_services.dart';
import 'package:pregathi/model/contacts.dart';
import 'package:pregathi/model/emergency_message.dart';
import 'package:pregathi/navigators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:background_sms/background_sms.dart';

class InstaShareBottomSheet extends StatefulWidget {
  const InstaShareBottomSheet({super.key});

  @override
  State<InstaShareBottomSheet> createState() => _InstaShareBottomSheetState();
}

class _InstaShareBottomSheetState extends State<InstaShareBottomSheet> {
  final User? user = FirebaseAuth.instance.currentUser;
  Position? _currentPosition;
  String? _currentAddress;
  String? _currentLat;
  String? _currentLong;
  String? _currentLocality;
  String? _currentPostal;
  LocationPermission? permission;
  late String husbandPhoneNumber;
  late String hospitalPhoneNumber;

  @override
  void initState() {
    super.initState();
    _getPermission();
    _getCurrentLocation();
    loadData();
    setWifeLocation();
  }

  setWifeLocation() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((wife) {
      setState(() {
        _currentAddress = wife['currentAddress'];
        _currentLat = wife['currentLatitude'];
        _currentLong = wife['currentLongitude'];
        _currentLocality = wife['locality'];
        _currentPostal = wife['postal'];
      });
    });
  }

  _getPermission() async => await [Permission.sms].request();
  isPermissionGranted() async => Permission.sms.status.isGranted;
  sendSMSwithAlert(String phoneNumber, String message, {int? simSlot}) async {
    await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
    ).then((SmsStatus status) {
      if (status == SmsStatus.sent) {
        Fluttertoast.showToast(msg: 'Sent alert to your trusted contacts...');
      } else {
        Fluttertoast.showToast(msg: "Oops! Failed to send");
      }
    });
  }

  sendSMS(String phoneNumber, String message, {int? simSlot}) async {
    await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
    );
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
        locality: _currentLocality,
        postal: _currentPostal,
        profilePic: userData['profilePic'],
      );

      final jsonData = userMessage.toJson();
      db.set(jsonData);

      List<Placemark> placeMarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placeMarks[0];

      final userMessagefinal = EmergencyMessageModel(
        name: userData['name'],
        id: user.uid,
        phone: userData['phone'],
        wifeEmail: userData['wifeEmail'],
        location: currentLocation,
        date: formatterDate,
        time: formatterTime,
        locality: place.locality ?? _currentLocality,
        postal: place.postalCode ?? _currentPostal,
        profilePic: userData['profilePic'],
      );

      final jsonDatafinal = userMessagefinal.toJson();
      db.set(jsonDatafinal);
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
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.4,
      decoration: const BoxDecoration(
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
            const Text(
              "Send current location immediately to your emergency contacts and nearby volunteers..",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 10,
            ),
            _currentAddress != null
                ? Text(
                    _currentAddress!,
                    textAlign: TextAlign.center,
                  )
                : smallProgressIndicator(context),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: MainButton(
                title: "Send Alert",
                onPressed: () async {
                  {
                    navigateToWifeEmergency(context);
                    permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied) {
                        Fluttertoast.showToast(
                            msg: 'Location permissions are denied');
                        return false;
                      }
                      if (permission == LocationPermission.deniedForever) {
                        Fluttertoast.showToast(
                            msg:
                                'Location permissions are permanently denied..');
                        return false;
                      }
                      return true;
                    }

                    List<TContact> contactList =
                        await DatabaseService().getContactList();

                    String msgBody =
                        "https://www.google.com/maps/search/?api=1&query=${_currentLat}%2C${_currentLong}. $_currentAddress";
                    String firebaseMsg =
                        "https://www.google.com/maps/search/?api=1&query=${_currentLat}%2C${_currentLong}";

                    setFirebaseEmergency(firebaseMsg);

                    if (await isPermissionGranted()) {
                      for (TContact contact in contactList) {
                        sendSMS(
                          contact.number,
                          "Having inconvenience, so reach please out at $msgBody",
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
  }
}
