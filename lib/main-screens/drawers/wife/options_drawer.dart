import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/community_home.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/bottom-bar/calendar_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/contacts_screen.dart';
import 'package:pregathi/widgets/home/wife-drawer/news_screen.dart';
import 'package:pregathi/widgets/home/wife-drawer/work_from_home.dart';
import 'package:sizer/sizer.dart';

class WifeOptionsDrawer extends ConsumerWidget {
  const WifeOptionsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Features',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Divider(
                height: 3,
                color: Colors.black,
                indent: 3.w,
                endIndent: 3.w,
              ),
              ListTile(
                title: Text("Community"),
                leading: Icon(Icons.groups_2_rounded),
                onTap: () {
                  goTo(context, CommunityHome());
                },
              ),
              ListTile(
                title: Text("AI Chat"),
                leading: Icon(Icons.mark_unread_chat_alt_rounded),
                onTap: () {
                  goTo(context, ChatScreen());
                },
              ),
              ListTile(
                title: Text("Contacts"),
                leading: Icon(Icons.contacts),
                onTap: () {
                  goTo(context, ContactsScreen());
                },
              ),
              ListTile(
                title: Text("Calender"),
                leading: Icon(Icons.calendar_month_rounded),
                onTap: () {
                  goTo(context, CalendarScreen());
                },
              ),
              ListTile(
                title: Text("Work from Home"),
                leading: Icon(Icons.work_rounded),
                onTap: () {
                  goTo(context, WorkFromHomeScreen());
                },
              ),
              ListTile(
                title: Text("Preg News"),
                leading: Icon(Icons.newspaper_outlined),
                onTap: () {
                  goTo(context, NewsScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}