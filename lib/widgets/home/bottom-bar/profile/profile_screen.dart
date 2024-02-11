import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/const/error_text.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/model/wife_profile.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile/profile_controller.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';

class ProfileScreenDummy extends ConsumerStatefulWidget {
  const ProfileScreenDummy({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfileScreenDummyState();
}

class _ProfileScreenDummyState extends ConsumerState<ProfileScreenDummy> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weekController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  File? profileFile;
  String? name;
  String? week;
  String? bio;
  String? _initialWeek;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _nameController.text = userData['name'];
        _weekController.text = userData['week'];
        _bioController.text = userData['bio'];
        _initialWeek = userData['week'];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weekController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void selectProfileImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  checkWeekUpdate() async {
    if (_initialWeek != _weekController.text) {
      DateTime now = DateTime.now();
      var current_year = now.year;
      var current_mon = now.month;
      var current_day = now.day;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'weekUpdatedDay': current_day,
        'weekUpdatedMonth': current_mon,
        'weekUpdatedYear': current_year,
        'weekUpdated': _weekController.text,
      });
    }
  }

  void save(WifeProfile wife) {
    ref.read(profileControllerProvider.notifier).editProfile(
          profileFile: profileFile,
          context: context,
          wife: wife,
          name: _nameController.text,
          week: _weekController.text,
          bio: _bioController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileControllerProvider);

    return ref.watch(getProfileByUidProvider(user!.uid)).when(
          data: (wife) => Scaffold(
            //backgroundColor: Pallete.
            appBar: AppBar(
              leading: BackButton(
                  color: Colors.white,
                  onPressed: () {
                    goToDisableBack(context, BottomPage());
                  }),
              title: const Text(
                "Profile",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: false,
              backgroundColor: primaryColor,
            ),
            body: isLoading
                ? progressIndicator(context)
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _buildProfileHeader(wife),
                        _buildPregnancyTracker(),
                        _buildHealthSection(),
                        _buildSubmitButton(wife),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
          ),
          loading: () => progressIndicator(context),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
        );
  }

  Widget _buildProfileHeader(WifeProfile wife) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: selectProfileImage,
            child: profileFile != null
                ? CircleAvatar(
                    backgroundImage: FileImage(profileFile!),
                    radius: 45,
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(wife.profilePic),
                    radius: 45,
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _weekController,
                  decoration:
                      const InputDecoration(labelText: 'Week of Pregnancy'),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyTracker() {
    // Assuming these are the total weeks of pregnancy.
    // You might want to fetch this value from user input or a database.
    final int totalWeeks = 36;

    // Fetch the user-inputted week of pregnancy (default to 0 if not set)
    int userWeek = int.tryParse(_weekController.text) ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text("Pregnancy Tracker",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: userWeek / totalWeeks,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
                primaryColor), // Change to your primaryColor
          ),
          const SizedBox(height: 10),
          Text("Week $userWeek", style: const TextStyle(fontSize: 16)),
          // Additional information or tips can be added here.
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Health Tips",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.fitness_center),
            title: Text("Daily Exercise"),
            subtitle: Text("30 minutes of walking or yoga is recommended."),
          ),
          ListTile(
            leading: Icon(Icons.restaurant),
            title: Text("Balanced Diet"),
            subtitle: Text("Include fruits, vegetables, and whole grains."),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(WifeProfile wife) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          checkWeekUpdate();
          save(wife);
        },
        child: const Text('Update Profile'),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
        onPressed: () {
          UserSharedPreference.setUserRole('');
          goToDisableBack(context, LoginScreen());
        },
        child: const Text('Logout'));
  }
}
