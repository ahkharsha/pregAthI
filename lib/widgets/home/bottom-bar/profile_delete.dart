import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pregathi/buttons/sub_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/db/shared_pref.dart';
import 'package:pregathi/main-screens/login-screen/login_screen.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
class DeleteProfileDialog extends StatefulWidget {
  @override
  _DeleteProfileDialogState createState() => _DeleteProfileDialogState();
}

class _DeleteProfileDialogState extends State<DeleteProfileDialog> {
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
      content: SizedBox(
        height: 150.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(translation(context).enterConfirm),
            Text(translation(context).noteDelete),
            TextField(
              controller: _deleteDialogController,
              decoration: InputDecoration(
                  hintText: "CONFIRM",
                  errorText: _validate ? 'Please enter CONFIRM' : null),
            ),
          ],
        ),
      ),
      actions: [
        SubButton(
          title: 'Delete',
          onPressed: () async {
            if (_deleteDialogController.text == 'CONFIRM') {
              await storeUserData();

              // Future.delayed(const Duration(milliseconds: 500), () {
              //   deleteUserAccount();
              // });
              deleteUserAccount();

              UserSharedPreference.setUserRole('');
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

  storeUserData() {
    DateTime now = DateTime.now();
    var formatterDate = DateFormat('dd/MM/yy').format(now);
    var formatterTime = DateFormat('kk:mm').format(now);
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'deletionDate': '${formatterTime}, ${formatterDate}',
    });
    DocumentReference copyFrom =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    DocumentReference copyTo =
        FirebaseFirestore.instance.collection('deleted-users').doc(user!.uid);

    copyFrom.get().then(
          (value) => {
            copyTo.set(
              value.data(),
            ),
          },
        );

    Future.delayed(const Duration(milliseconds: 500), () {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
    });
  }

  deleteUserAccount() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        dialogueBox(context,
            'Account deletion requires a Re-Login. Try deleting the account after you login again');
      } else {
        showSnackBar(context, e.toString());
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
