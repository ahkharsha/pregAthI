import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';

class Hospital extends StatelessWidget {
  final Function? onMapFunction;

  const Hospital({Key? key, this.onMapFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              onMapFunction!('Hospitals near me');
            },
            child: Card(
              color: boxColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset(
                    'assets/images/services/hospital.png',
                    height: 32,
                  ),
                ),
              ),
            ),
          ),
          Text(
            translation(context).hospitals,
          )
        ],
      ),
    );
  }
}
