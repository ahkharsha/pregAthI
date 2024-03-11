// Google Gemini API has been used here

import 'package:flutter/material.dart';
import 'package:pregathi/bottom-sheet/insta_share_bottom_sheet.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/ai-chat/chat/image_chat.dart';
import 'package:pregathi/widgets/home/ai-chat/chat/text_chat.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:sizer/sizer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
                  onPressed: () {
                    goToDisableBack(context, BottomPage());
                  }),
              title: Text(
                translation(context).aiChat,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: false,
              
              bottom: TabBar(
                labelColor: Colors.white,
                indicatorColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 5,
                tabs: [
                  Tab(text: translation(context).text),
                  Tab(text: translation(context).image),
                ],
              ),
            ),
            floatingActionButton: Padding(
                padding: EdgeInsets.only(bottom: 35.h, right: 5.0),
                child: FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return InstaShareBottomSheet();
                      },
                    );
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: boxColor,
                  highlightElevation: 50,
                  child: Icon(
                    Icons.warning_outlined,
                  ),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                TextChat(),
                ImageChat(),
              ],
            )));
  }
}
