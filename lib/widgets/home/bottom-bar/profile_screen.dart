import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          checkWeekUpdate();
          _updateProfile();
        },
        child: const Text('Update Profile'),
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

      dialogueBoxWithButton(context, 'Profile updated successfully!');

      setState(() {
        isSaving = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error. Could not update profile.');
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
          child: const Text('Logout')),
    );
  }

  Widget _buildDeleteAccountButton() {
    return ElevatedButton(
        onPressed: () async {
          showDeleteDialog(context);
        },
        child: const Text('Delete Account'));
  }
}

showDeleteDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => DeleteDialogContent(),
  );
}

class DeleteDialogContent extends StatefulWidget {
  @override
  _DeleteDialogContentState createState() => _DeleteDialogContentState();
}

class _DeleteDialogContentState extends State<DeleteDialogContent> {
  final TextEditingController _deleteDialogController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Confirm Account Deletion',
        textAlign: TextAlign.center,
      ),
      content: SizedBox( // Wrap content in a SizedBox to control height
        height: 175.0, // Set desired height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter CONFIRM to delete your account'),
            Text(
              'Note: Once deleted, you cannot create another account using the same email'),
            TextField(
              controller: _deleteDialogController,
              decoration: InputDecoration(
                hintText: "CONFIRM",
                errorText: _validate
                    ? 'Please enter CONFIRM'
                    : null),
            ),
          ],
        ),
      ),
      actions: [
        SubButton(
          title: 'Delete',
          onPressed: () {
              if (_deleteDialogController.text == 'CONFIRM') {
                DocumentReference copyFrom = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid);
                DocumentReference copyTo = FirebaseFirestore.instance
                    .collection('deleted-users')
                    .doc(user!.uid);

                copyFrom.get().then(
                      (value) => {
                    copyTo.set(
                      value.data(),
                    ),
                  },
                );
                UserSharedPreference.setUserRole('');
                _deleteDialogController.dispose();
                goToDisableBack(context, LoginScreen());
                Future.delayed(const Duration(microseconds: 1), () {
                  dialogueBoxWithButton(
                      context, 'Your account has been deleted successfully!');
                });
              } else {
                setState(() {
                  _validate = true;
                });
                
              }
          },
        ),
      ],
    );
  }
}

