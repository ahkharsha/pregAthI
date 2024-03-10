import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/community-chat/feed/feed_screen.dart';
import 'package:pregathi/community-chat/post/controller/post_controller.dart';
import 'package:pregathi/community-chat/post/screens/add_post_screen.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/model/post.dart';

// ignore: constant_identifier_names
const String pregathiWebsiteLink = "https://pregathi-website.vercel.app/";
const String pregathiAboutUsLink= "https://ahkharsha.github.io/assets/pregAthI/videos/aboutUs.mp4";
String pregathiSupportEmail= 'pregathi2024@gmail.com';

const apiKey = "AIzaSyCAYDrBcb41UV2-2inRihCUS80VdRWv6vs";
const bannerDefault = 'https://img.freepik.com/free-vector/young-women-group-standing-camp_25030-39599.jpg';
const avatarDefault =
    'https://cdn-icons-png.flaticon.com/512/1474/1474494.png';

const wifeProfileDefault =
    'https://cdn-icons-png.flaticon.com/512/4406/4406029.png';

const volunteerProfileDefault =
    'https://cdn-icons-png.flaticon.com/512/9337/9337706.png';

// Disha's
Color primaryColor = Color.fromARGB(255, 174, 110, 165);
// Color textColor = Color.fromARGB(255, 174, 110, 165);

// Harsha's
// Color primaryColor = Color.fromARGB(255, 158, 59, 144);

// Final
Color textColor = Color.fromARGB(255, 93, 11, 82);

// Color appBgColor=Color.fromARGB(255, 252, 213, 246);
Color appBgColor = Color.fromARGB(255, 254, 233, 251);

Color boxColor = Colors.white;

const tabWidgets = [
  FeedScreen(),
  AddPostScreen(),
];

void goTo(BuildContext context, Widget nextScreen) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => nextScreen,
      ));
}

void goToDisableBack(BuildContext context, Widget nextScreen) {
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => nextScreen,
      ));
}

void goBack(BuildContext context) {
  Navigator.of(context).pop();
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
}

dialogueBox(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    ),
  );
}

dialogueBoxWithButton(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
      actions: [
        SubButton(
          title: 'Ok',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    ),
  );
}

logoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Do you want to log out?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
      actions: [
        SubButton(
          title: 'No',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        SubButton(
          title: 'Yes',
          onPressed: () async {
            goToDisableBack(context, LoginScreen());
            await FirebaseAuth.instance.signOut();
            UserSharedPreference.setUserRole('');
          },
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    ),
  );
}

deletePostConfirmation(Post post, WidgetRef ref, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Do you want to delete the post?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
      actions: [
        SubButton(
          title: 'No',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        SubButton(
          title: 'Yes',
          onPressed: () async {
            deletePost(post, ref, context);
            Navigator.of(context).pop();
          },
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    ),
  );
}

void deletePost(Post post, WidgetRef ref, BuildContext context) async {
  ref.read(postControllerProvider.notifier).deletePost(post, context);
}

Widget progressIndicator(BuildContext context) {
  return Center(
    child: CircularProgressIndicator(
      backgroundColor: textColor,
      color: appBgColor,
      strokeWidth: 7,
    ),
  );
}

Widget smallProgressIndicator(BuildContext context) {
  return Center(
    child: Transform.scale(
      scale: 0.7,
      child: CircularProgressIndicator(
        backgroundColor: primaryColor,
        color: appBgColor,
        strokeWidth: 7,
      ),
    ),
  );
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);

  return image;
}

List<String> bannedWords = [
  'fuck',
  'motherfucker',
  'fucker',
  'asshole',
  'shit',
  'bitch',
  'cunt',
  'bastard',
  'cock',
  'dick',
  'pussy',
  'whore',
  'slut',
  'nigger',
  'nigga',
  'faggot',
  'retard',
  'twat',
  'wanker',
  'arsehole',
  'bollocks',
  'douchebag',
  'sucker',
  'cuck',
  'dildo',
  'asshat',
  'anus',
  'spastic',
  'bugger',
  'knob',
  'sperm',
  'cum',
  'tits',
  'boobs',
  'titfuck',
  'nipple',
  'vagina',
  'penis',
  'testicle',
  'balls',
  'pubes',
  'clit',
  'fanny',
];

bool checkForBannedWords(String text) {
    for (String word in bannedWords) {
      if (text.toLowerCase().contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }