import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:sizer/sizer.dart';

class Ambulance extends StatelessWidget {
  const Ambulance({super.key});

  _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 5),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () => _callNumber('102'),
          child: Container(
            height: 160.h,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: boxColor),
             
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withOpacity(0),
                    child: Image.asset('assets/images/emergency/ambulance.png'),
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        translation(context).ambulance,
                        style: TextStyle(
                            color:textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.06),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          translation(context).clickToCall,
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.045),
                        ),
                      ),
                      Container(
                         height: 4.h,
                        width: 18.w,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '102',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
