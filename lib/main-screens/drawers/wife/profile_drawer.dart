import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/navigators.dart';

class WifeProfileDrawer extends ConsumerWidget {
  const WifeProfileDrawer({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              color: primaryColor,
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return dialogueBox(context,
                            'Some error has occurred ${snapshot.error}');
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
                              backgroundImage:
                                  NetworkImage(userData['profilePic']),
                              radius: 40,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              userData['name'],
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
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
              title: Text(translation(context).profile),
              leading: Icon(Icons.person_outline_outlined),
              onTap: () => navigateToWifeProfile(context),
            ),
            ListTile(
              title: Text(translation(context).announcements),
              leading: Icon(Icons.notifications_active_outlined),
              onTap: () => navigateToAnnouncement(context),
            ),
            ListTile(
              title: Text(translation(context).languages),
              leading: const Icon(Icons.language_rounded),
              onTap: () => navigateToLanguageSelection(context, LANGUAGE_CODE),
            ),
            ListTile(
              title: Text(translation(context).about),
              leading: const Icon(Icons.info_outline_rounded),
              onTap: () => navigateToAboutUs(context),
            ),
            ListTile(
              title: Text('Options'),
              leading: const Icon(Icons.settings_rounded),
              onTap: () => navigateToOptions(context),
            ),
            ListTile(
              title: Text(translation(context).logout),
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
