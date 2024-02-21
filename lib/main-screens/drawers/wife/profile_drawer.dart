import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_screen.dart';

class WifeProfileDrawer extends ConsumerWidget {
  const WifeProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              ListTile(
                title: Text("Profile"),
                leading: Icon(Icons.person),
                onTap: () {
                  goTo(context, WifeProfileScreen());
                },
              ),
              ListTile(
                title: Text("Logout"),
                leading: Icon(Icons.logout_rounded),
                onTap: () {
                  UserSharedPreference.setUserRole('');
                  goTo(context, LoginScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
