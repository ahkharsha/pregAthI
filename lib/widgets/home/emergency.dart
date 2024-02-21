import 'package:flutter/material.dart';
import 'package:pregathi/widgets/home/emergency/ambulance.dart';
import 'package:pregathi/widgets/home/emergency/police.dart';
import 'package:sizer/sizer.dart';

class Emergency extends StatelessWidget {
  const Emergency({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 23.h,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          Ambulance(),
          Police(),
        ],
      ),
    );
  }
}
