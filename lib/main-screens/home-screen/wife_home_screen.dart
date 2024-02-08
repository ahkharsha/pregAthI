import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pregathi/community-chat/delegate/search_community_delegate.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/ai-chat/ai_chat.dart';
import 'package:pregathi/community-chat/community_list_drawer.dart';
import 'package:pregathi/widgets/home/emergency.dart';
import 'package:pregathi/widgets/home/services.dart';
import 'package:pregathi/widgets/home/insta_share/insta_share.dart';
import 'package:url_launcher/url_launcher.dart';

class WifeHomeScreen extends ConsumerStatefulWidget {
  const WifeHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<WifeHomeScreen> {
  final String currentVersion = "1.0.0";

  // ignore: unused_field
  String? currentAddress;
  Position? _currentPosition;

  void drawerDisplay(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  //Remove this function to cancel checkUpdates everytime wife home screen is opened
  _checkUpdate() async {
    DocumentSnapshot versionDetails = await FirebaseFirestore.instance
        .collection('pregAthI')
        .doc('version')
        .get();

    if (currentVersion != versionDetails['latestVersion']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(
              'A newer version of the app is available. Please download to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  String googleUrl =
                      'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

                  final Uri _url = Uri.parse(googleUrl);
                  try {
                    await launchUrl(_url);
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'Error');
                  }
                },
                child: Text('Download'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
        ),
      );
    }
  }

  _getCurrentLocation() async {
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true,
    ).then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition!.latitude);
        _getAddressFromLaLo();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLaLo() async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placeMarks[0];
      setState(() {
        currentAddress =
            "${place.locality},${place.postalCode},${place.street},${place.name},${place.subLocality}";
            print(currentAddress);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState() {
    _checkUpdate();
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "pregAthI",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 25),
        ),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => drawerDisplay(context),
            //icon: Icon(Icons.groups),
            icon: Icon(Icons.menu),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search),
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      drawer: CommunityDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: ListView(
              shrinkWrap: true,
              children:  [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Emergency',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Emergency(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Services(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'AI Chat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                AIChat(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Insta-Share',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                InstaShare(currentAddress: currentAddress),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
