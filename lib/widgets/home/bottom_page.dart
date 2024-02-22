import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/community-chat/community_home.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/home-screen/wife_home_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/contacts_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_screen.dart';

class BottomPage extends StatefulWidget {
  BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  late final String uid;
  late int currentIndex;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    currentIndex = 0;
    pages = [
      WifeHomeScreen(),
      ContactsScreen(),
      CommunityHome(),
      ChatScreen(),
      WifeProfileScreen(),
    ];
  }

  void onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: appBgColor,
        color: primaryColor,
        onTap: onTapped,
        items: const [
          CurvedNavigationBarItem(
              // label: 'Home',
              child: Icon(
                Icons.home,
                color: Colors.white,
              )),
          CurvedNavigationBarItem(
              // label: 'Contacts',
              child: Icon(
                Icons.contacts,
                color: Colors.white,
              )),
          CurvedNavigationBarItem(
              // label: 'Forum',
              child: Icon(
                Icons.groups,
                color: Colors.white,
              )),
          CurvedNavigationBarItem(
              // label: 'AI Chat',
              child: Icon(
                Icons.mark_chat_unread_rounded,
                color: Colors.white,
              )),
          CurvedNavigationBarItem(
              // label: 'Profile',
              child: Icon(
                Icons.person,
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}
