import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';
import 'package:pregathi/navigators.dart';
import 'package:sizer/sizer.dart';

class RemoveMembersScreen extends ConsumerStatefulWidget {
  final String name;

  const RemoveMembersScreen({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  ConsumerState<RemoveMembersScreen> createState() =>
      _RemoveMembersScreenState();
}

class _RemoveMembersScreenState extends ConsumerState<RemoveMembersScreen> {
  int ctr = 0;
  Set<String> uids = {};
  Set<String> modUids = {};
  Set<String> removeUids = {};
  Set<String> finalUids = {};
  final User? user = FirebaseAuth.instance.currentUser;
  bool isListViewBuilderComplete = false;

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
    if (removeUids.isEmpty) {
      navigateToModTools(context, widget.name);
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text(
            'Remove the following members?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.sp),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => goBack(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                for (var uid in uids) {
                  if (!removeUids.contains(uid)) {
                    finalUids.add(uid);
                  }
                }

                ref.read(communityControllerProvider.notifier).removeMembers(
                      widget.name,
                      finalUids.toList(),
                      context,
                      user!.uid,
                    );
                goBack(context);
              },
              child: const Text('Yes'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );
    }
  }

  Widget _buildCheckboxTile(String member, List<String> mods) {
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(member);
    return FutureBuilder<DocumentSnapshot>(
      future: _reference.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        if (snapshot.hasError) {
          return ErrorText(error: snapshot.error.toString());
        }
        String name = snapshot.data!['name'];
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
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => goBack(context),
        ),
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
          FutureBuilder<Widget>(
            future: Future.delayed(const Duration(seconds: 1), () {
              if (modUids.length == uids.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'There are no members to remove.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox.shrink(); // Return an empty widget if condition is not met
              }
            }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // Return a placeholder widget while waiting for the future to complete
              } else if (snapshot.hasError) {
                return ErrorText(error: snapshot.error.toString());
              } else {
                return snapshot.data ?? SizedBox.shrink(); // Return the widget from the future, or an empty SizedBox if null
              }
            },
          ),
          Expanded(
            child: ref.watch(getCommunityByNameProvider(widget.name)).when(
                  data: (community) {
                    isListViewBuilderComplete = false;
                    return ListView.builder(
                      itemCount: community.members.length,
                      itemBuilder: (BuildContext context, int index) {
                        final member = community.members[index];

                        return FutureBuilder<Widget>(
                          future: Future(
                            () => _buildCheckboxTile(member, community.mods),
                          ),
                          builder: (context, snapshot) {
                            if (index == community.members.length - 1) {
                              isListViewBuilderComplete = true;
                            }
                            if (community.members.contains(member) &&
                                (ctr >= 0 && ctr < community.members.length)) {
                              uids.add(member);
                            }
                            if (community.mods.contains(member) &&
                                (ctr >= 0 && ctr < community.mods.length)) {
                              modUids.add(member);
                            }
                            ctr++;
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            } else if (snapshot.hasError) {
                              return ErrorText(
                                error: snapshot.error.toString(),
                              );
                            } else {
                              return snapshot.data!;
                            }
                          },
                        );
                      },
                    );
                  },
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
