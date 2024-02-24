import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/controller/community_controller.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<AddModsScreen> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int ctr = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    print('The final mods are');
    print(uids);
    ref.read(communityControllerProvider.notifier).addMods(
          widget.name,
          uids.toList(),
          context,
          user!.uid,
        );
  }

  Future<CheckboxListTile> _buildCheckboxTile(String member) async {
    DocumentReference<Map<String, dynamic>> _reference =
        FirebaseFirestore.instance.collection('users').doc(member);
    DocumentSnapshot userData = await _reference.get();

    String name = userData['name'];
    return CheckboxListTile(
      value: uids.contains(member),
      onChanged: (val) {
        if (val!) {
          addUid(member);
        } else {
          removeUid(member);
        }
      },
      title: Text(name),
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
            onPressed: saveMods,
            icon: Icon(Icons.done),
          )
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) => ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (BuildContext context, int index) {
                // print('The members of the community are');
                // print(community.members);
                final member = community.members[index];

                return FutureBuilder<CheckboxListTile>(
                  future: _buildCheckboxTile(member),
                  builder: (context, snapshot) {
                    if (community.mods.contains(member) &&
                        (ctr >= 0 && ctr <= community.mods.length+1)) {
                      print('adding a member to uid');
                      print(member);
                      uids.add(member);
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
    );
  }
}
