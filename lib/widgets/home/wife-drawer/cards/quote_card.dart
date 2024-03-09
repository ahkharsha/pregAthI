import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:sizer/sizer.dart';

class QuoteCard extends ConsumerWidget {
  final String quote;

  QuoteCard({
    Key? key,
    required this.quote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            height: 1.h,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(50),
              
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                quote,
                style: const TextStyle(fontSize: 14.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 1.h,
          )
        ],
      ),
    );
  }
}
