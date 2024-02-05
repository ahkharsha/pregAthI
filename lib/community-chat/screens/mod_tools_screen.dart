import 'package:flutter/material.dart';
import 'package:pregathi/community-chat/screens/edit_community_screen.dart';
import 'package:pregathi/const/constants.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod Tools'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text('Add Moderators'),
            onTap: () {},
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
