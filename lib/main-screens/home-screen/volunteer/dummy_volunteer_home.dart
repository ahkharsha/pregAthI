import 'package:basics/basics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/drawers/wife/profile_drawer.dart';
import 'package:pregathi/main-screens/drawers/wife/options_drawer.dart';
import 'package:pregathi/main.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/user_permission.dart';
import 'package:pregathi/widgets/home/ai-chat/ai_chat.dart';
import 'package:pregathi/widgets/home/emergency.dart';
import 'package:pregathi/widgets/home/services.dart';
import 'package:pregathi/widgets/home/insta_share/insta_share.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pregathi/multi-language/classes/language.dart';

class VolunteerHomeScreen extends ConsumerStatefulWidget {
  const VolunteerHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends ConsumerState<VolunteerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? profilePic = volunteerProfileDefault;

  void openOptionsDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void openProfileDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          translation(context).pregAthI,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 20.sp,
          ),
        ),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => openOptionsDrawer(context),
            icon: Icon(
              Icons.menu_rounded,
              color: Colors.white,
            ),
          );
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<Language>(
              underline: const SizedBox(),
              icon: const Icon(
                Icons.language,
                color: Colors.white,
              ),
              onChanged: (Language? language) async {
                if (language != null) {
                  Locale _locale = await setLocale(language.languageCode);
                  MyApp.setLocale(context, _locale);
                }
              },
              items: Language.languageList()
                  .map<DropdownMenuItem<Language>>(
                    (e) => DropdownMenuItem<Language>(
                      value: e,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            e.flag,
                            style: TextStyle(fontSize: 25.sp),
                          ),
                          Text(e.name)
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.045),
            child: GestureDetector(
              onTap: openProfileDrawer,
              child: CircleAvatar(
                backgroundColor: Colors.black,
                radius: 15.5,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profilePic!),
                  radius: 15,
                ),
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      drawer: WifeOptionsDrawer(),
      endDrawer: WifeProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).emergency,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Emergency(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).services,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Services(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).instaShare,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const InstaShare(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 15),
                    child: Text(
                      translation(context).aiChat,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const AIChat(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
