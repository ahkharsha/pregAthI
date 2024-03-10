import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/regular_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/wife-drawer/cards/text_card.dart';
import 'package:sizer/sizer.dart';

class CommunityRulesScreen extends StatefulWidget {
  CommunityRulesScreen({Key? key}) : super(key: key);

  @override
  State<CommunityRulesScreen> createState() => _CommunityRulesScreenState();
}

class _CommunityRulesScreenState extends State<CommunityRulesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
            onPressed: () {
              goBack(context);
            }),
        title: Text(
          "Community Rules",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0, bottom: 20, left: 20, right: 20
              ),
              child: Text(
                'Please adhere to these guidelines consistently when engaging with the community.',
                style:
                    TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
              ),
            ),
            TextCard(
              title: 'Rule 1 - Respect',
              content:
                  'Respect the diversity of opinions and beliefs within the community.',
            ),
            TextCard(
              title: 'Rule 2 - AutoBan',
              content:
                  '\n\nRefrain from posting any inappropriate or offensive content. Initial warnings will be issued, with subsequent violations resulting in account bans.',
              boldText: 'There is an Automatic Banning System (ABS) in place.',
            ),
            TextCard(
              title: 'Rule 3 - No Spam',
              content: 'Do not spam or engage in excessive self-promotion.',
            ),
            TextCard(
              title: 'Rule 4 - Relevant Discussions',
              content:
                  'Keep discussions relevant to the community’s topics and themes.',
            ),
            TextCard(
              title: 'Rule 5 - Privacy',
              content:
                  'Respect the privacy of other members; do not share personal information without consent.',
            ),
            TextCard(
              title: 'Rule 6 - No Discrimination',
              content:
                  'Do not engage in discriminatory behavior or hate speech based on race, ethnicity, gender, religion, etc.',
            ),
            TextCard(
              title: 'Rule 7 - Factual Accuracy',
              content:
                  'Avoid posting misleading or false information; strive for accuracy and honesty.',
            ),
            SizedBox(
              height: 2.h,
            ),
            RegularButton(
              title: 'Ok',
              onPressed: () {
                goBack(context);
                _updateReadGuidelines();
              },
            ),
            SizedBox(
              height: 25,
            )
          ],
        ),
      ),
    );
  }

  _updateReadGuidelines() async {
    final User? user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'readGuidelines': true,
    });
  }
}
