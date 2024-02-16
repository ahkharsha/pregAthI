import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/delegate/search_community_delegate.dart';
import 'package:pregathi/community-chat/screens/community_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/community-chat/screens/create_community_screen.dart';

class CommunityHome extends ConsumerStatefulWidget {
  const CommunityHome({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommunityHomeState();
}

class _CommunityHomeState extends ConsumerState<CommunityHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "pregAthI",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 25),
        ),
        // leading: Builder(builder: (context) {
        //   return IconButton(
        //     onPressed: () => drawerDisplay(context),
        //     //icon: Icon(Icons.groups),
        //     icon: Icon(Icons.menu),
        //   );
        // }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search),
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text("Create a community.."),
              leading: Icon(Icons.add),
              onTap: () {
                goTo(context, CreateCommunityScreen());
              },
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
                          thisItem['name'] == '3rd Trimester') {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(thisItem['avatar']),
                          ),
                          title: Text('${thisItem['name']}'),
                          onTap: () {
                            goTo(context,
                                CommunityScreen(name: '${thisItem['name']}'));
                          },
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
