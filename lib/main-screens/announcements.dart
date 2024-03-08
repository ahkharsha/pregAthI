import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/regular_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/wife-drawer/cards/text_card.dart';
import 'package:sizer/sizer.dart';

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
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 20, left: 20, right: 20),
                  child: Text(
                    'There are no new announcements right now. Come back later!',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 15.sp,),
                  ),
                ),
              );
            }

            List<Widget> announcementTiles = [];

            data.forEach(
              (key, value) {
                announcementTiles.add(
                  TextCard(
                      title: '${announcementTiles.length + 1}. $key',
                      content: value.toString()),
                );
              },
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 20, left: 20, right: 20),
                  child: Text(
                    'Here are the latest announcements!',
                    style:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                ...announcementTiles,
                SizedBox(
                  height: 2.h,
                ),
                RegularButton(
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
