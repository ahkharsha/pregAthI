import 'package:flutter/material.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';

class AIChat extends StatelessWidget {
  const AIChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 5,right: 15),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            );
          },
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 208, 9, 248),
                  Color.fromARGB(255, 226, 98, 252),
                  Color.fromARGB(255, 237, 189, 248),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0),
                          child: Image.asset('assets/images/ai-chat/ai.png'),
                        ),
                      ),
                      Text(
                        'AI Chat',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.06),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0,right: 14),
                    child: Text(
                      'Click to chat with AI about pregnancy and more...',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.045),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 30,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Chat',
                          style: TextStyle(
                            color: Color.fromARGB(255, 208, 9, 248),
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
