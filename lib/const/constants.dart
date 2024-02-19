import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/community-chat/feed/feed_screen.dart';
import 'package:pregathi/community-chat/post/screens/add_post_screen.dart';

// ignore: constant_identifier_names
const apiKey = "AIzaSyCAYDrBcb41UV2-2inRihCUS80VdRWv6vs";
const bannerDefault =
    'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';
const avatarDefault =
    'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2';

const wifeProfileDefault =
    'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';

const volunteerProfileDefault =
    'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';

Color primaryColor = Color.fromARGB(255, 208, 9, 248);

const tabWidgets = [
  FeedScreen(),
  AddPostScreen(),
];

const IconData upIcon =
    IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
const IconData downIcon =
    IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

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

Widget progressIndicator(BuildContext context) {
  return Center(
    child: CircularProgressIndicator(
      backgroundColor: primaryColor,
      color: Color.fromARGB(255, 241, 198, 250),
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
        color: Color.fromARGB(255, 241, 198, 250),
        strokeWidth: 7,
      ),
    ),
  );
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);

  return image;
}
