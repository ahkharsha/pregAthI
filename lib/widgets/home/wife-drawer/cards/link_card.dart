import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/const/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkCard extends ConsumerWidget {
  final String title;
  final String content;
  final String link;

  LinkCard({
    Key? key,
    required this.title,
    required this.content,
    required this.link,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final Uri _url = Uri.parse(link);
                      try {
                        await launchUrl(_url);
                      } catch (e) {
                        Fluttertoast.showToast(msg: 'Error');
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          content,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Color.fromARGB(255, 39, 149, 239),
                            decoration: TextDecoration.underline,
                            decorationColor: Color.fromARGB(255, 39, 149, 239),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3.h,
          )
        ],
      ),
    );
  }
}
