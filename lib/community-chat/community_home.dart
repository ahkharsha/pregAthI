import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/community-chat/community_list_drawer.dart';
import 'package:pregathi/community-chat/delegate/search_community_delegate.dart';
import 'package:pregathi/const/constants.dart';

class CommunityHome extends ConsumerStatefulWidget {
  const CommunityHome({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommunityHomeState();
}

class _CommunityHomeState extends ConsumerState<CommunityHome> {
  int _page = 0;

  void drawerDisplay(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
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
