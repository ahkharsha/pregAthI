import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/const/constants.dart';

class AnnouncementScreen extends StatefulWidget {
  AnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              _updateLastAnnouncement();
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Announcements",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pregAthI')
              .doc('announcements')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            Map<String, dynamic>? data =
                snapshot.data?.data() as Map<String, dynamic>?;

            if (data == null || data.isEmpty) {
              return Center(
                child: Text('There are no new announcements'),
              );
            }

            List<Widget> announcementTiles = [];

            data.forEach((key, value) {
              announcementTiles.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ListTile(
                    title: Text(
                      '${announcementTiles.length + 1}. $key',
                      style: TextStyle(fontSize: 19),
                    ),
                    subtitle: Text(
                      value.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            });

            return ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: announcementTiles,
                ),
                SubButton(
                  title: 'Done',
                  onPressed: () {
                    _updateLastAnnouncement();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }

  _updateLastAnnouncement() async {
    final User? user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot announcement = await FirebaseFirestore.instance
        .collection('pregAthI')
        .doc('version')
        .get();

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'lastAnnouncement': announcement['latestAnnouncement'],
    });
  }
}