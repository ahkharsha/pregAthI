import 'package:flutter/material.dart';
import 'package:pregathi/community-chat/screens/add_mods_screen.dart';
import 'package:pregathi/community-chat/screens/edit_community_screen.dart';
import 'package:pregathi/community-chat/screens/remove_members_screen.dart';
import 'package:pregathi/const/constants.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
            onPressed: () {
              goBack(context);
            }),
        backgroundColor: primaryColor,
        title: const Text(
          "Mod Tools",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.remove_moderator_rounded),
            title: const Text('Remove Members'),
            onTap: () {goTo(context, RemoveMembersScreen(name: name,));},
          ),
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text('Add Moderators'),
            onTap: () {goTo(context, AddModsScreen(name: name,));},
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Community'),
            onTap: () {goTo(context, EditCommunityScreen(name: name,));},
          ),
        ],
      ),
    );
  }
}
