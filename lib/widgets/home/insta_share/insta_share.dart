import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pregathi/buttons/main_button.dart';
import 'package:pregathi/model/contacts.dart';
import 'package:pregathi/db/db_services.dart';

class InstaShare extends StatefulWidget {
  const InstaShare({super.key});

  @override
  State<InstaShare> createState() => _InstaShareState();
}

class _InstaShareState extends State<InstaShare> {
  Position? _currentPosition;
  String? _curentAddress;
  LocationPermission? permission;
  _getPermission() async => await [Permission.sms].request();
  isPermissionGranted() async => Permission.sms.status.isGranted;
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

  _getAddressFromLaLo() async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placeMarks[0];
      setState(() {
        _curentAddress =
            "${place.locality},${place.postalCode},${place.street},${place.name},${place.subLocality}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  showModelInstaShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.4,
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
                if (_currentPosition != null) Text(_curentAddress!),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: MainButton(
                    title: "Send Alert",
                    onPressed: () async {
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
                      List<TContact> contactList =
                          await DatabaseService().getContactList();

                      if (_currentPosition != null) {
                        String msgBody =
                            "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_curentAddress";

                        if (await isPermissionGranted()) {
                          for (TContact contact in contactList) {
                            sendSMS(
                              contact.number,
                              "Having inconvenience, so reach out at $msgBody",
                            );
                          }
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
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
            height: 180,
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
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      ListTile(
                        title: Padding(
                          padding:
                              const EdgeInsets.only(top: 6.0, bottom: 14.0),
                          child: Text(
                            "Send Location",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06),
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
                                    MediaQuery.of(context).size.width * 0.045),
                          ),
                        ),
                      ),
                    ],
                  )),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/insta-share/route.jpg',
                        height: 120,
                        width: 130,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
