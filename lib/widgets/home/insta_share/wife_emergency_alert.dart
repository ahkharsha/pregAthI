import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:http/http.dart' as http;
import 'package:pregathi/const/constants.dart';

class WifeEmergencyScreen extends StatefulWidget {
  WifeEmergencyScreen({super.key});

  @override
  State<WifeEmergencyScreen> createState() => _WifeEmergencyScreenState();
}

class _WifeEmergencyScreenState extends State<WifeEmergencyScreen> {
  late DocumentReference _documentReference;
  final User? user = FirebaseAuth.instance.currentUser;

  _sendVolunteerNotification() async {
    final QuerySnapshot<Map<String, dynamic>> userQuery =
        await FirebaseFirestore.instance.collection('users').get();

    final DocumentSnapshot<Map<String, dynamic>> wifeData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

    for (final userData in userQuery.docs) {
      // Check if the user's role is 'volunteer'
      if (userData['role'] == 'volunteer' &&
          ((wifeData['locality'] == userData['locality']) ||
              (wifeData['postal'] == userData['postal']))) {
        print(
            '${userData['name']} is a volunteer and he lives in the same area as mom');
        try {
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAAXCg-vuA:APA91bGXbejVgs3Mz5Uvv-OGWI1KnWbROO8NAibXZ-WDid_dRVCTbgqGwtPJjr9a6hiLKiITypDIyaiFJZk6QQkJnJh9K-K6Px5KurZmBo0g4qv67iSg9_96wwm3bzJegfViBl1QDlGX'
              },
              body: jsonEncode(<String, dynamic>{
                'priority': 'high',
                'data': <String, dynamic>{
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  'status': 'done',
                  'id': '1',
                },
                "notification": <String, dynamic>{
                  "title": 'Emergency!!!',
                  "body": 'Nearby mom in emergency!',
                },
                "to": userData['token'],
                
              }));
              print('message sent');
        } catch (e) {
          Fluttertoast.showToast(msg: e.toString());
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    
    _sendVolunteerNotification();
    _playEmergencySound();
  }
  void _playEmergencySound() async {
    final player = AudioPlayer();  
    const audioPath = "alert/emergency-alarm-with-reverb-29431.mp3";
    await player.play(AssetSource(audioPath));
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Emergency!!!",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/emergency-alert/emergency_alert.png',
                      height: 300,
                      width: 300,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SubButton(
                        title: 'Cancel Emergency',
                        onPressed: () {
                          _documentReference = FirebaseFirestore.instance
                              .collection('emergencies')
                              .doc(user!.uid);

                          _documentReference.delete();
                          Navigator.of(context).pop();
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}