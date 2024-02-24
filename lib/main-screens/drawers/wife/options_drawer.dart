import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/community_home.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/bottom-bar/calendar_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/contacts_screen.dart';
import 'package:pregathi/widgets/home/wife-drawer/music_list.dart';
import 'package:pregathi/widgets/home/wife-drawer/news_screen.dart';
import 'package:pregathi/widgets/home/wife-drawer/work_from_home.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';

class WifeOptionsDrawer extends ConsumerWidget {
  const WifeOptionsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 56,
              color: primaryColor,
              width: double.infinity,
            ),
            Container(
              color: primaryColor,
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      translation(context).features,
                      style: const TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0,
              color: Colors.black,
              indent: 0,
              endIndent: 0,
              thickness: 2,
            ),
            ListTile(
              title: Text(translation(context).community),
              leading: const Icon(Icons.groups_2_rounded),
              onTap: () {
                goTo(context, const CommunityHome());
              },
            ),
            ListTile(
              title: Text(translation(context).aiChat),
              leading: const Icon(Icons.mark_unread_chat_alt_rounded),
              onTap: () {
                goTo(context, const ChatScreen());
              },
            ),
            ListTile(
              title: Text(translation(context).contacts),
              leading: const Icon(Icons.contacts),
              onTap: () {
                goTo(context, const ContactsScreen());
              },
            ),
            ListTile(
              title: Text(translation(context).calendar),
              leading: const Icon(Icons.calendar_month_rounded),
              onTap: () {
                goTo(context, const CalendarScreen());
              },
            ),
            ListTile(
              title: Text(translation(context).musicPlayer),
              leading: const Icon(Icons.music_note_rounded),
              onTap: () {
                goTo(context, const MusicListScreen());
              },
            ),
            ListTile(
              title: Text(translation(context).workFromHome),
              leading: const Icon(Icons.work_rounded),
              onTap: () {
                goTo(context, const WorkFromHomeScreen());
              },
            ),
            ListTile(
              title: Text(translation(context).pregNews),
              leading: const Icon(Icons.newspaper_outlined),
              onTap: () {
                goTo(context, const NewsScreen());
              },
            ),
            
          ],
        ),
      ),
    );
  }
}
