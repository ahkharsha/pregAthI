import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/variable_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:sizer/sizer.dart';

class NewCommunityRulesScreen extends StatefulWidget {
  NewCommunityRulesScreen({Key? key}) : super(key: key);

  @override
  State<NewCommunityRulesScreen> createState() =>
      _NewCommunityRulesScreenState();
}

class _NewCommunityRulesScreenState extends State<NewCommunityRulesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              goToDisableBack(context, BottomPage());
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
              padding: const EdgeInsets.only(top: 15.0, bottom: 10, left: 15),
              child: Text(
                'Accept the following rules to proceed using communities',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            ListTile(
              title: Text(
                'Rule 1',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Be respectful to all members of the community.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 2',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Avoid using offensive language or engaging in personal attacks.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 3',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Column(
                children: [
                  Text(
                    'There is an Automatic Banning System (ABS) in place',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Refrain from posting any inappropriate or offensive content. Initial warnings will be issued, with subsequent violations resulting in account bans.',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                'Rule 4',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Respect the diversity of opinions and beliefs within the community.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 5',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Do not spam or engage in excessive self-promotion.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 6',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Report any violations of these rules to the moderators.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 7',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Keep discussions relevant to the community’s topics and themes.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 8',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Respect the privacy of other members; do not share personal information without consent.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 9',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Do not engage in discriminatory behavior or hate speech based on race, ethnicity, gender, religion, etc.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 10',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Avoid posting misleading or false information; strive for accuracy and honesty.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 11',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Respect the decisions and directives of community moderators and administrators.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(
                'Rule 12',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Use appropriate language and tone; avoid excessive shouting or use of all caps.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
            ),
            VariableButton(
              title: 'Agree',
              onPressed: () {
                goToDisableBack(context, BottomPage());
                _updateReadGuidelines();
              },
            ),
            SizedBox(
              height: 50,
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
    goToDisableBack(context, BottomPage());
    Future.delayed(const Duration(microseconds: 1), () {
      dialogueBoxWithButton(context, "You can now proceed using Communities");
    });
  }
}
