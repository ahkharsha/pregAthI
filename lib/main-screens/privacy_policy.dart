import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Privacy Policy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                'Introduction',
                'Welcome to pregAthI, an app designed to empower women around the world. At pregAthI, we take your privacy and security seriously. This privacy policy outlines how we collect, use, and protect your personal information.',
                Colors.black,
              ),
              const SizedBox(height: 20.0),
              _buildCard(
                'Data Collection',
                'We collect your email id, username, and profile picture when you create an account on pregAthI. This information is stored securely on Firebase servers provided by Google. We do not share, sell, or disclose your personal information to any third party.',
                Colors.black,
              ),
              const SizedBox(height: 20.0),
              _buildCard(
                'Data Protection',
                'At pregAthI, we take the security of your personal information seriously. We use industry-standard security measures to protect your data. All data is protected, and access to our servers is restricted to authorized personnel only.',
                Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              content,
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
