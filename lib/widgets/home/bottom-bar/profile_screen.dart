import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_delete.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class WifeProfileScreen extends StatefulWidget {
  const WifeProfileScreen({super.key});

  @override
  _WifeProfileScreenState createState() => _WifeProfileScreenState();
}

class _WifeProfileScreenState extends State<WifeProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weekController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? profilePic = wifeProfileDefault;
  String? _initialWeek;
  final User? user = FirebaseAuth.instance.currentUser;
  File? newProfilePic;
  bool isSaving = false;

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
        profilePic = userData['profilePic'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              goToDisableBack(context, BottomPage());
            }),
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: primaryColor, // Change to your primaryColor
      ),
      body: isSaving
          ? progressIndicator(context)
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildProfileHeader(),
                  _buildPregnancyTracker(),
                  _buildHealthSection(),
                  _buildSubmitButton(),
                  _buildLogoutButton(),
                  _buildDeleteAccountButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              await _pickImage();
            },
            child: newProfilePic != null
                ? CircleAvatar(
                    backgroundImage: FileImage(newProfilePic!),
                    radius: 45,
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(profilePic!),
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
                  decoration:
                      InputDecoration(labelText: translation(context).name),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _weekController,
                  decoration:
                      InputDecoration(labelText: translation(context).weekOfPregnancy),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                TextFormField(
                  controller: _bioController,
                  decoration:
                      InputDecoration(labelText: translation(context).bio),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        newProfilePic = File(res.files.first.path!);
      });
    }
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
           Text(translation(context).pregnancyTracker,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: userWeek / totalWeeks,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
                primaryColor), // Change to your primaryColor
          ),
          const SizedBox(height: 10),
          Text("${translation(context).week} $userWeek", style: const TextStyle(fontSize: 16)),
          // Additional information or tips can be added here.
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(translation(context).healthTips,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(translation(context).dailyExercise),
            subtitle: Text(translation(context).aboutDailyExercise),
          ),
          ListTile(
            leading:const Icon(Icons.restaurant),
            title: Text(translation(context).balancedDiet),
            subtitle: Text(translation(context).aboutBalancedDiet),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          checkWeekUpdate();
          _updateProfile();
        },
        child:  Text(translation(context).updateProfile),
      ),
    );
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

  Future<void> _updateProfile() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      setState(() {
        isSaving = true;
      });

      // Update profile picture if it's changed
      String? downloadUrl;
      if (newProfilePic != null) {
        print(newProfilePic);
        downloadUrl = await _uploadImage(newProfilePic!);
      }

      // Update other profile information
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': _nameController.text,
        'week': _weekController.text,
        'bio': _bioController.text,
        if (downloadUrl != null)
          'profilePic': downloadUrl
        else
          'profilePic': profilePic,
      });

      dialogueBoxWithButton(context, translation(context).diologueUpdateProfileSuccess);

      setState(() {
        isSaving = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: translation(context).diologueUpdateProfileFailure);
    }
  }

  Future<String?> _uploadImage(File filePath) async {
    try {
      final fileName = const Uuid().v4();
      final Reference fbStorage =
          FirebaseStorage.instance.ref('profile').child(fileName);
      final UploadTask uploadTask = fbStorage.putFile(filePath);
      await uploadTask;
      return await fbStorage.getDownloadURL();
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            UserSharedPreference.setUserRole('');
            goTo(context, LoginScreen());
          },
          child:  Text(translation(context).logout)),
    );
  }

  Widget _buildDeleteAccountButton() {
    return ElevatedButton(
        onPressed: () async {
          showDeleteDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: Text(
          translation(context).deleteAccount,
          style: const TextStyle(
            color: Colors.white,
          ),
        ));
  }
}

showDeleteDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => DeleteDialogContent(),
  );
}
