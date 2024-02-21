import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/register-screen/wife_register_screen.dart';

class DisplayWifeRegister extends StatelessWidget {
  const DisplayWifeRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 70),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WifeRegisterScreen()),
            );
          },
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
             color: boxColor
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/images/login/wife.png',height: 80,
                                  width: 80,),
                  ),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.038,
                      width: MediaQuery.of(context).size.width * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Mom',
                          style: TextStyle(
                            color:textColor,
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

