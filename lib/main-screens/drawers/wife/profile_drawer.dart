import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/announcements.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_screen.dart';
import 'package:sizer/sizer.dart';

class WifeProfileDrawer extends ConsumerWidget {
  const WifeProfileDrawer({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return dialogueBox(
                      context, 'Some error has occurred ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return progressIndicator(context);
                }

                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(userData['profilePic']),
                        radius: 40,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        userData['name'],
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                );
              },
            ),
            Divider(
              height: 3,
              color: Colors.black,
              indent: 3.w,
              endIndent: 3.w,
            ),
            SizedBox(
              height: 5,
            ),
            ListTile(
              title: Text("Profile"),
              leading: Icon(Icons.person),
              onTap: () {
                goTo(context, WifeProfileScreen());
              },
            ),
            ListTile(
              title: Text("Announcements"),
              leading: Icon(Icons.announcement_rounded),
              onTap: () {
                goTo(context, AnnouncementScreen());
              },
            ),
            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout_rounded),
              onTap: () {
                logoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
