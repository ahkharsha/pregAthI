import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pregathi/community-chat/community_home.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/home-screen/wife_home_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/contacts_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_screen.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomPage extends StatefulWidget {
  const BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  late final String uid;
  late int currentIndex;
  late List<Widget> pages;
  late double dragStartX;
  final double swipeSensitivity = 2;

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

  void onHorizontalDragStart(DragStartDetails details) {
    dragStartX = details.globalPosition.dx;
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    final dx = details.globalPosition.dx;
    final delta = dx - dragStartX;
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth / swipeSensitivity;
    if (delta.abs() > threshold) {
      if (delta > 0) {
        setState(() {
          if (currentIndex > 0) {
            currentIndex--;
          }
        });
      } else {
        setState(() {
          if (currentIndex < pages.length - 1) {
            currentIndex++;
          }
        });
      }
      dragStartX = dx;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: appBgColor,
          color: primaryColor,
          onTap: onTapped,
          index: currentIndex,
          items: const [
            CurvedNavigationBarItem(
              child: Icon(Icons.home, color: Colors.white),
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.contacts, color: Colors.white),
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.groups, color: Colors.white),
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.mark_chat_unread_rounded, color: Colors.white),
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
