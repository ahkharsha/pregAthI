import 'package:flutter/material.dart';
// import 'package:pregathi/main-screens/help_screen.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/navigators.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
            onPressed: () => goBack(context)),
        backgroundColor: primaryColor,
        title: const Text(
          "Options",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          ListTile(
              title: Text('Contact Us'),
              leading: const Icon(Icons.email_outlined),
              onTap: () => navigateToContactUs(context),
            ),
            ListTile(
              title: Text('Privacy Policy'),
              leading: const Icon(Icons.security_outlined),
              onTap: () => navigateToPrivacyPolicy(context),
            ),
            // ListTile(
            //   title: Text('Help'),
            //   leading: const Icon(Icons.help_outline_outlined),
            //   onTap: () => navigateToHelp(context),
            // ),
        ],
      ),
    );
  }
}
