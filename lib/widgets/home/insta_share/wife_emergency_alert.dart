import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/const/constants.dart';

class WifeEmergencyScreen extends StatefulWidget {
   WifeEmergencyScreen({super.key});

  @override
  State<WifeEmergencyScreen> createState() => _WifeEmergencyScreenState();
}

class _WifeEmergencyScreenState extends State<WifeEmergencyScreen> {
  late DocumentReference _documentReference;
  final User? user = FirebaseAuth.instance.currentUser;

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
                    child: Image.asset('assets/images/emergency-alert/emergency_alert.png',height: 300,width: 300,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SubButton(title: 'Cancel Emergency', onPressed: () {
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
          ))),
    );
  }
}
