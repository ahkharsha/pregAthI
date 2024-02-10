import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/loader.dart';
import 'package:pregathi/main-screens/home-screen/volunteer_home_screen.dart';

class VolunteerProfileScreen extends StatelessWidget {
  VolunteerProfileScreen({super.key});

  checkCurrentDate(String time, String date, String locality, String postal) {
    DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd/MM/yy').format(now);
    if (formatterDate == date) {
      return Text('${time}, Today - ${locality}, ${postal}');
    } else {
      return Text('${time}, ${date} - ${locality}, ${postal}');
    }
  }

  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final CollectionReference _reference = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('past-services');
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              goTo(context, VolunteerHomeScreen());
            }),
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
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

                return GestureDetector(
                  child: ListTile(
                    title: Text('${thisItem['name']}'),
                    subtitle: checkCurrentDate(
                        thisItem['time'],
                        thisItem['date'],
                        thisItem['locality'],
                        thisItem['postal']),
                  ),
                );
              },
            );
          }

          return Loader();
        },
      ),
    );
  }
}
