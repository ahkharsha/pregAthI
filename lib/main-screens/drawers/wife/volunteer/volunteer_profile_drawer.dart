import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/about_us.dart';
import 'package:pregathi/main-screens/announcements.dart';
import 'package:pregathi/main-screens/contact_us.dart';
import 'package:pregathi/main-screens/help_screen.dart';
import 'package:pregathi/main-screens/home-screen/volunteer/volunteer_profile_screen.dart';
import 'package:pregathi/main-screens/privacy_policy.dart';

class VolunteerProfileDrawer extends ConsumerWidget {
  const VolunteerProfileDrawer({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: primaryColor,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: StreamBuilder<DocumentSnapshot>(
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
                      padding: const EdgeInsets.only(bottom: 10.0, top: 30),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(userData['profilePic']),
                        radius: 40,
                      ),
                    ),
                    Text(
                      userData['name'],
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(
            height: 0,
            color: Colors.black,
            thickness: 2,
          ),
          SizedBox(
            height: 5,
          ),
          ListTile(
            title: Text("Profile"),
            leading: Icon(Icons.person_outline_outlined),
            onTap: () {
              goTo(context, VolunteerProfileScreen());
            },
          ),
          ListTile(
            title: Text("Announcements"),
            leading: Icon(Icons.notifications_active_outlined),
            onTap: () {
              goTo(context, AnnouncementScreen());
            },
          ),
          ListTile(
            title: Text("About Us"),
            leading: const Icon(Icons.info_outline_rounded),
            onTap: () {
              goTo(context, AboutUsScreen());
            },
          ),
          ListTile(
            title: Text('Contact Us'),
            leading: const Icon(Icons.email_outlined),
            onTap: () {
              goTo(context, ContactUsScreen());
            },
          ),
          ListTile(
            title: Text('Privacy Policy'),
            leading: const Icon(Icons.security_outlined),
            onTap: () {
              goTo(context, PrivacyPolicyScreen());
            },
          ),
          ListTile(
              title: Text('Help'),
              leading: const Icon(Icons.help_outline_outlined),
              onTap: () {
                goTo(context, HelpScreen());
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
    );
  }
}
