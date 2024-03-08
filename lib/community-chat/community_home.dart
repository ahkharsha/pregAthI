import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/community_list_drawer.dart';
import 'package:pregathi/community-chat/community_rules_screen.dart';
import 'package:pregathi/community-chat/delegate/search_community_delegate.dart';
import 'package:pregathi/community-chat/new_community_guidelines.dart';
import 'package:pregathi/const/constants.dart';

class CommunityHome extends ConsumerStatefulWidget {
  const CommunityHome({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommunityHomeState();
}

class _CommunityHomeState extends ConsumerState<CommunityHome> {
  int _page = 0;
  bool readGuidelines = true;

  @override
  void initState() {
    _checkReadGuidelines();
    super.initState();
  }

  void drawerDisplay(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  _checkReadGuidelines() async {
    final User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
      
    print(userData['readGuidelines']);

    if (!userData['readGuidelines']) {
      setState(() {
        readGuidelines = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!readGuidelines) {
      return NewCommunityRulesScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Communities",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () => drawerDisplay(context),
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
            );
          }),
          actions: [
            IconButton(
              onPressed: () {
                goTo(context, CommunityRulesScreen());
              },
              icon: const Icon(
                Icons.rule_outlined,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: SearchCommunityDelegate(ref));
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        drawer: CommunityDrawer(),
        body: tabWidgets[_page],
        bottomNavigationBar: CupertinoTabBar(
          activeColor: primaryColor,
          backgroundColor: appBgColor,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(
                  top: 8.0,
                  bottom: 8,
                ),
                child: Icon(Icons.home),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(
                  bottom: 8.0,
                  top: 8,
                ),
                child: Icon(Icons.add),
              ),
              label: '',
            ),
          ],
          onTap: onPageChanged,
          currentIndex: _page,
        ),
      );
    }
  }
}
