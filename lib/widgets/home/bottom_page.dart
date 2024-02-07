import 'package:flutter/material.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';
import 'package:pregathi/main-screens/home-screen/wife_home_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/add_contacts.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/calendar_screen.dart';

class BottomPage extends StatefulWidget {
  BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    WifeHomeScreen(),
    AddContactsScreen(),
    CalendarScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];
  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
        items: const [
          BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(
                Icons.home,
              )),
          BottomNavigationBarItem(
              label: 'Contacts',
              icon: Icon(
                Icons.contacts,
              )),
          BottomNavigationBarItem(
              label: 'Calender',
              icon: Icon(
                Icons.calendar_month_rounded,
              )),
          BottomNavigationBarItem(
              label: 'AI Chat',
              icon: Icon(
                Icons.mark_unread_chat_alt_rounded,
              )),
          BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(
                Icons.person,
              )),
        ],
      ),
    );
  }
}
