import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/navigators.dart';

class CommunityDrawer extends ConsumerWidget {
  const CommunityDrawer({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text("Create a community.."),
              leading: Icon(Icons.add),
              onTap: () => navigateToCreateCommunity(context),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('communities')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return dialogueBox(
                      context, 'Some error has occurred ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return progressIndicator(context);
                }

                List<Map<String, dynamic>> items = snapshot.data!.docs
                    .map(
                      (community) => {
                        'members': community['members'],
                        'name': community['name'],
                        'avatar': community['avatar'],
                      },
                    )
                    .toList();

                return Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final String userUid =
                          FirebaseAuth.instance.currentUser!.uid;
                      Map<String, dynamic> thisItem = items[index];
                      print(thisItem['members']);

                      if (thisItem['name'] == '1st Trimester' ||
                          thisItem['name'] == '2nd Trimester' ||
                          thisItem['name'] == '3rd Trimester' ||
                          thisItem['name'] == 'Art' ||
                          thisItem['name'] == 'Fitness' ||
                          thisItem['name'] == 'Music') {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(thisItem['avatar']),
                          ),
                          title: Text('${thisItem['name']}'),
                          onTap: () => navigateToCommunity(context, thisItem['name']),
                          
                          trailing: Transform.rotate(
                            angle: 45 * math.pi / 180,
                            child: Icon(Icons.push_pin_rounded),
                          ),
                        );
                      }

                      if (thisItem['members'].contains(userUid)) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(thisItem['avatar']),
                          ),
                          title: Text('${thisItem['name']}'),
                          onTap: () => navigateToCommunity(context, thisItem['name']),
                        );
                      }

                      return Container();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
