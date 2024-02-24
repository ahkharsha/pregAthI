import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/widgets/home/bottom-bar/chat_screen.dart';
import 'package:sizer/sizer.dart';

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
            goTo(context, ChatScreen());
          },
          child: Container(
            height: MediaQuery.of(context).size.height*0.25,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
              color: boxColor
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
                          radius: 22.sp,
                          backgroundColor: Colors.white.withOpacity(0),
                          child: Image.asset('assets/images/ai-chat/ai.png'),
                          
                        ),
                      ),
                      Text(
                        translation(context).aiChat,
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.06),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0,right: 14,),
                    child: Text(
                      translation(context).aboutChat,
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.045),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Center(
                    child: Container(
                      height: 4.h,
                      width: 20.w,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Chat',
                          style: TextStyle(
                            color:  Colors.white,
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
