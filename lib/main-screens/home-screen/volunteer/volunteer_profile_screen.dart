import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/widgets/home/bottom-bar/profile_delete.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';

class VolunteerProfileScreen extends StatefulWidget {
  VolunteerProfileScreen({super.key});

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? profilePic = volunteerProfileDefault;
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
        _bioController.text = userData['bio'];
        profilePic = userData['profilePic'];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  checkCurrentDate(String time, String date, String locality, String postal) {
    DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd/MM/yy').format(now);
    if (formatterDate == date) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${locality}, ${postal}'),
          Text('${time}, Today'),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${locality}, ${postal}'),
          Text('${time}, ${date}'),
        ],
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              _updateProfile();
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
      body: isSaving
          ? progressIndicator(context)
          : Column(
              children: [
                _buildProfileHeader(),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 25.0,
                    bottom: 8,
                    left: 15,
                    right: 15,
                  ),
                  child: Text(
                    'Moms saved',
                    style:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('past-services')
                      .snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasError) {
                      return dialogueBox(
                          context, 'Some error has occurred ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return progressIndicator(context);
                    }

                    List<dynamic> items = snapshot.data!.docs
                        .map(
                          (emergency) => {
                            'id': emergency['id'],
                            'name': emergency['name'],
                            'location': emergency['location'],
                            'date': emergency['date'],
                            'phone': emergency['phone'],
                            'time': emergency['time'],
                            'wifeEmail': emergency['wifeEmail'],
                            'locality': emergency['locality'],
                            'postal': emergency['postal'],
                          },
                        )
                        .toList();

                    return Expanded(
                      child: items.length == 0
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Text(
                                      'You have not saved any moms yet. Go save one!',
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> thisItem = items[index];

                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, bottom: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: boxColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        '${thisItem['name']}',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: checkCurrentDate(
                                          thisItem['time'],
                                          thisItem['date'],
                                          thisItem['locality'],
                                          thisItem['postal']),
                                    ),
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
                _buildDeleteAccountButton(),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return ElevatedButton(
        onPressed: () {
          showDeleteDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: Text(
          translation(context).deleteAccount,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
          ),
        ));
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
        'bio': _bioController.text,
        if (downloadUrl != null)
          'profilePic': downloadUrl
        else
          'profilePic': profilePic,
      });

      dialogueBoxWithButton(
          context, translation(context).diologueUpdateProfileSuccess);

      setState(() {
        isSaving = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: translation(context).diologueUpdateProfileFailure);
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
}

showDeleteDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => DeleteProfileDialog(),
  );
}
