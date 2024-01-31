import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/ai_chat.dart';
import 'package:pregathi/widgets/community-chat/community_list_drawer.dart';
import 'package:pregathi/widgets/home/emergency.dart';
import 'package:pregathi/widgets/home/services.dart';
import 'package:pregathi/widgets/home/insta_share/insta_share.dart';

class WifeHomeScreen extends StatelessWidget {
  const WifeHomeScreen({super.key});

  void drawerDisplay(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

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
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: ()=>drawerDisplay(context),
              //icon: Icon(Icons.groups),
              icon: Icon(Icons.menu),
            );
          }
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      drawer: CommunityDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: ListView(
              shrinkWrap: true,
              children: const [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Emergency',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Emergency(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Services(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'AI Chat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                AIChat(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Insta-Share',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                InstaShare(),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
