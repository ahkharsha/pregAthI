import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pregathi/widgets/home/services/hospital.dart';
import 'package:pregathi/widgets/home/services/pharmacy.dart';
import 'package:pregathi/widgets/home/services/police_station.dart';

class Services extends StatelessWidget {
  const Services({Key? key}) : super(key: key);

  static Future<void> openMap(String location) async {
    String googleUrl = 'https://www.google.com/maps/search/$location';

    /*if (Platform.isAndroid) {
      if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrl(Uri.parse(googleUrl));
      } else {
        throw 'Could not launch $googleUrl';
      }
    }*/

    final Uri _url = Uri.parse(googleUrl);
    try {
      await launchUrl(_url);
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          Hospital(onMapFunction: openMap),
          Pharmacy(onMapFunction: openMap),
          PoliceStation(onMapFunction: openMap),
        ],
      ),
    );
  }
}