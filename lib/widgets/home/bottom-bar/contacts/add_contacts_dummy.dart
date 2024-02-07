import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/buttons/full_screen_button.dart';
import 'package:pregathi/db/db_services.dart';
import 'package:pregathi/model/contacts.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/contacts_screen.dart';
import 'package:sqflite/sqflite.dart';

class AddContactsScreen extends StatefulWidget {
  const AddContactsScreen({Key? key}) : super(key: key);

  @override
  State<AddContactsScreen> createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends State<AddContactsScreen> {
  DatabaseService _databaseHelper = DatabaseService();
  List<TContact>? contactList;
  String? husbandPhoneNumber;
  String? hospitalPhoneNumber;

  int count = 0; // Initialize count to 0

  void listShow() {
    Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<TContact>> contactListFuture =
          _databaseHelper.getContactList();
      contactListFuture.then((value) {
        setState(() {
          this.contactList = value;
          this.count = value.length;
        });
      });
    });
  }

  Future<void> loadData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        // husbandPhoneNumber = userData['husbandPhone'];
        husbandPhoneNumber = userData['husbandEmail'];
        hospitalPhoneNumber = userData['hospitalPhone'];
      });
    }
  }

  deleteCon(TContact contact) async {
    int result = await _databaseHelper.deleteContact(contact.id);
    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact removed successfully..");
      listShow();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      listShow();
    });
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (contactList == null) {
      contactList = [];
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          "Trusted Contacts",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              FullScreenButton(
                title: "Add Trusted Contacts",
                onPressed: () async {
                  bool result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactsScreen(),
                    ),
                  );
                  if (result == true) {
                    listShow();
                  }
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: count +
                      2, // Increase count by 2 for husband and hospital contacts
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      // Display husband contact at index 0
                      return buildContactTile(
                        'Husband Contact',
                        Icons.person,
                        index - 2,
                        husbandPhoneNumber,
                      );
                    } else if (index == 1) {
                      // Display hospital contact at index 1
                      return buildContactTile(
                        'Hospital Contact',
                        Icons.local_hospital,
                        index - 2,
                        hospitalPhoneNumber,
                      );
                    } else {
                      // Display remaining contacts
                      return buildContactTile(
                        contactList![index - 2].name,
                        Icons.person,
                        index - 2,
                        contactList![index - 2].number,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContactTile(
      String name, IconData icon, int index, String? phoneNumber) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(name),
          leading: Icon(icon),
          trailing: phoneNumber != null
              ? Container(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await FlutterPhoneDirectCaller.callNumber(
                              phoneNumber);
                        },
                        icon: Icon(
                          Icons.call,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          deleteCon(contactList![index]);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
