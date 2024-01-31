import 'package:flutter/material.dart';
import 'package:pregathi/main-screens/register-screen/volunteer_register_screen.dart';

class DisplayVolunteerRegister extends StatelessWidget {
  const DisplayVolunteerRegister({super.key});

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
              MaterialPageRoute(builder: (context) => VolunteerRegisterScreen()),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/images/login/volunteer.png',height: 80,
                                  width: 80,),
                  ),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.038,
                      width: MediaQuery.of(context).size.width * 0.30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Volunteer',
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