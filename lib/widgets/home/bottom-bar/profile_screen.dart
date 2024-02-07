import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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
  String? profilePic;
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
              goTo(context, BottomPage());
            }),
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: primaryColor, // Change to your primaryColor
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildProfileHeader(),
            _buildPregnancyTracker(),
            _buildHealthSection(),
            _buildSubmitButton(),
            _buildLogoutButton(),
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
            child: CircleAvatar(
              radius: 40,
              backgroundImage: profilePic != null
                  ? NetworkImage(profilePic!)
                  : const AssetImage('assets/images/profile/default_profile.png')
                      as ImageProvider,
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
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _weekController,
                  decoration: const InputDecoration(labelText: 'Week of Pregnancy'),
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
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      setState(() {
        profilePic = pickedImage.path;
      });
    }
  }

  Future<String?> _uploadImage(String filePath) async {
    try {
      final fileName = const Uuid().v4();
      final Reference fbStorage =
          FirebaseStorage.instance.ref('profile').child(fileName);
      final UploadTask uploadTask = fbStorage.putFile(File(filePath));
      await uploadTask;
      return await fbStorage.getDownloadURL();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }

  Future<void> _updateProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        setState(() {
          isSaving = true;
        });

        // Update profile picture if it's changed
        String? downloadUrl;
        if (profilePic != null) {
          downloadUrl = await _uploadImage(profilePic!);
        }

        // Update other profile information
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'week': _weekController.text,
          'bio': _bioController.text,
          if (downloadUrl != null) 'profilePic': downloadUrl,
        });

        Fluttertoast.showToast(msg: 'Profile updated successfully');
      } catch (error) {
        Fluttertoast.showToast(msg: 'Error updating profile: $error');
      } finally {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildPregnancyTracker() {
    // Assuming these are the total weeks of pregnancy.
    // You might want to fetch this value from user input or a database.
    final int totalWeeks = 40;

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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Change to your primaryColor
          ),
          const SizedBox(height: 10),
          Text("Week $userWeek of $totalWeeks", style: const TextStyle(fontSize: 16)),
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
        child: isSaving
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  _updateProfile();
                },
                child: const Text('Update Profile'),
              ));
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
        onPressed: () {
          UserSharedPreference.setUserRole('');
              goTo(context, LoginScreen());
        },
        child: const Text('Logout'));
  }
}