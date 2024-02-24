import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/model/firebase_data.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkCard extends ConsumerWidget {
  final FirebaseData firebaseData;
  WorkCard({
    Key? key,
    required this.firebaseData,
  });

  checkCurrentDate(String time, String date) {
    DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd/MM/yy').format(now);
    if (formatterDate == date) {
      print('The date and time is');
      print(date);
      print(time);
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 30, bottom: 10),
        child: Text(
          '${time}, Today',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 30, bottom: 10),
        child: Text(
          '${time}, ${date}',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
          child: GestureDetector(
            onTap: () async {
              final Uri _url = Uri.parse(firebaseData.url);
              try {
                await launchUrl(_url);
              } catch (e) {
                Fluttertoast.showToast(msg: 'Error');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ).copyWith(right: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, bottom: 10, right: 30),
                                  child: Text(
                                    'Field - ${firebaseData.title}',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 30.0, left: 15),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  width: double.infinity,
                                  child: Image.network(
                                    firebaseData.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, bottom: 10, right: 30),
                                  child: Text(
                                    firebaseData.description,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              checkCurrentDate(
                                  firebaseData.time, firebaseData.date)
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
