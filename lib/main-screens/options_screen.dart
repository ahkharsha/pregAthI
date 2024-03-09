import 'package:flutter/material.dart';
import 'package:pregathi/main-screens/contact_us.dart';
import 'package:pregathi/main-screens/help_screen.dart';
import 'package:pregathi/main-screens/privacy_policy.dart';
import 'package:pregathi/const/constants.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              goBack(context);
            }),
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
              onTap: () {
                goTo(context, ContactUsScreen());
              },
            ),
            ListTile(
              title: Text('Privacy Policy'),
              leading: const Icon(Icons.security_outlined),
              onTap: () {
                goTo(context, PrivacyPolicyScreen());
              },
            ),
            ListTile(
              title: Text('Help'),
              leading: const Icon(Icons.help_outline_outlined),
              onTap: () {
                goTo(context, HelpScreen());
              },
            ),
        ],
      ),
    );
  }
}
