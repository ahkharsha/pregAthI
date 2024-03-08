import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:sizer/sizer.dart';

class TextCard extends ConsumerWidget {
  final String title;
  final String content;
  final String? boldText;

  TextCard({
    Key? key,
    required this.title,
    required this.content,
    this.boldText,
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text.rich(
                    TextSpan(
                      children: [
                        if (boldText != null)
                          TextSpan(
                            text: boldText,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        TextSpan(
                          text: content,
                          style: const TextStyle(fontSize: 18.0),
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
