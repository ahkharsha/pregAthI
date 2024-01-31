import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/community-chat/screens/create_community_screen.dart';

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
            )
          ],
        ),
      ),
    );
  }
}
