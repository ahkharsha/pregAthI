import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';

class RemoveMembersScreen extends ConsumerStatefulWidget {
  final String name;
  const RemoveMembersScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<RemoveMembersScreen> createState() => _RemoveMembersScreenState();
}

class _RemoveMembersScreenState extends ConsumerState<RemoveMembersScreen> {
  int ctr = 0;
  Set<String> uids = {};
  Set<String> modUids = {};
  Set<String> removeUids = {};
  Set<String> finalUids = {};
  final User? user = FirebaseAuth.instance.currentUser;

  void addUid(String uid) {
    setState(() {
      removeUids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      removeUids.remove(uid);
    });
  }

  void saveMembers() {
    print('The full list of members is');
    print(uids);

    print('The uids to remove is');
    print(removeUids);
    finalUids = uids.difference(removeUids);

    print('The final list of members is');
    print(finalUids);

    ref.read(communityControllerProvider.notifier).removeMembers(
          widget.name,
          finalUids.toList(),
          context,
          user!.uid,
        );
  }

  Widget _buildCheckboxTile(String member, List<String> mods) {
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(member);
    return FutureBuilder<DocumentSnapshot>(
      future: _reference.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(); // Return a placeholder while loading
        }
        if (snapshot.hasError) {
          return ErrorText(error: snapshot.error.toString()); // Return an error widget if there's an error
        }
        String name = snapshot.data!['name'];
        // Check if the member is not in community.mods
        if (!mods.contains(member)) {
          return CheckboxListTile(
            value: removeUids.contains(member),
            onChanged: (val) {
              if (val!) {
                addUid(member);
              } else {
                removeUid(member);
              }
            },
            title: Text(name),
          );
        } else {
          // Return an empty Container if the member is in community.mods
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              goBack(context);
            }),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            onPressed: saveMembers,
            icon: Icon(Icons.done),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (modUids.length == uids.length)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  'There are no members to remove.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Expanded(
            child: ref.watch(getCommunityByNameProvider(widget.name)).when(
              data: (community) => ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (BuildContext context, int index) {
                  final member = community.members[index];

                  return FutureBuilder<Widget>(
                    future: Future(() => _buildCheckboxTile(member, community.mods)),
                    builder: (context, snapshot) {
                      if (community.members.contains(member) &&
                          (ctr >= 0 && ctr < community.members.length)) {
                            print('In this cycle, the UID is');
                            print(member);
                        uids.add(member);
                      }
                       if (community.mods.contains(member) &&
                          (ctr >= 0 && ctr < community.mods.length)) {
                            print('In this cycle, the UID is');
                            print(member);
                        modUids.add(member);
                      }
                      ctr++;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return ErrorText(error: snapshot.error.toString());
                      } else {
                        return snapshot.data!;
                      }
                    },
                  );
                },
              ),
              error: (error, stackTrace) => ErrorText(
                error: error.toString(),
              ),
              loading: () => progressIndicator(context),
            ),
          ),
        ],
      ),
    );
  }
}
