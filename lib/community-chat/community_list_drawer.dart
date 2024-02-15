import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/screens/community_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/community-chat/screens/create_community_screen.dart';

class CommunityDrawer extends ConsumerWidget {
  const CommunityDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text("Create a community.."),
              leading: Icon(Icons.add),
              onTap: () {
                goTo(context, CreateCommunityScreen());
              },
            ),
            FutureBuilder(
              future:
                  FirebaseFirestore.instance.collection('communities').get(),
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
                        (community) => {
                          'members': community['members'],
                          'name':community['name'],
                          'avatar':community['avatar'],
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
                    
                        if (thisItem['members'].contains(userUid)) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(thisItem['avatar']),
                            ),
                            title: Text('${thisItem['name']}'),
                            onTap: () {
                              goTo(context,
                                  CommunityScreen(name: '${thisItem['name']}'));
                            },
                       
                          );
                        }
                    
                        return Container();
                      },
                    ),
                  );
                }

                return progressIndicator(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
