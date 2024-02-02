import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/ai-chat/chat/image_chat.dart';
import 'package:pregathi/widgets/home/ai-chat/chat/text_chat.dart';

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
              leading: BackButton(color: Colors.white),
              title: const Text(
                "AI Chat",
                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
              ),
              centerTitle: false,
              bottom: const TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.label, 
                indicatorWeight: 5,     
                tabs: [
                  Tab(text: "Text"),
                  Tab(text: "Image"),
                ],
              ),
            ),
            body: const TabBarView(
              children: [TextChat(), ImageChat()],
            )));
  }
}