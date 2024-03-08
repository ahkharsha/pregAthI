import 'package:flutter/material.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/main-screens/contact_us.dart';
import 'package:pregathi/widgets/home/wife-drawer/cards/text_card.dart';
import 'package:sizer/sizer.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only( bottom: 20, left: 20, right: 20),
                  child: Text(
                    'Last Updated: March 08, 2024\n\nThis Privacy Policy describes the policies and procedures on the collection, use and disclosure of your information when you use this service.',
                    style:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              TextCard(
                  title: 'About this service',
                  content:
                      'Welcome to pregAthI, an app crafted to support you throughout your pregnancy journey. At pregAthI, we prioritize the security and confidentiality of your personal information. This privacy policy elucidates our practices in collecting, utilizing, and safeguarding your data.'),
              TextCard(
                  title: 'Information Gathering',
                  content:
                      'When you register an account on pregAthI, we gather your email address, username, and profile image. This data is securely stored on Firebase servers operated by Google. Rest assured, we never distribute, trade, or reveal your personal details to external parties.'),
              TextCard(
                  title: 'Ensuring Data Security',
                  content:
                      'At pregAthI, safeguarding your personal information is paramount to us. We employ industry-standard security protocols to shield your data. Access to our servers is restricted to authorized personnel, ensuring comprehensive protection for all data.'),
              TextCard(
                  title: 'Data Utilization Guidelines',
                  content:
                      ' The data collected by pregAthI is used solely for enhancing user experience and providing personalized services. We adhere to strict guidelines regarding the utilization of your information to ensure transparency and accountability.'),
              TextCard(
                  title: 'Data Retention Period',
                  content:
                      'pregAthI retains user data only for as long as necessary to fulfill the purposes outlined in our Privacy Policy. Once the data is no longer required, it is securely deleted or anonymized to protect user privacy.'),
              GestureDetector(
                onTap: () {
                  goToDisableBack(context, ContactUsScreen());
                },
                child: TextCard(
                    title: 'Contact Us',
                    content:
                        'If you have any questions about this Privacy Policy, you can contact us at $pregathiSupportEmail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
