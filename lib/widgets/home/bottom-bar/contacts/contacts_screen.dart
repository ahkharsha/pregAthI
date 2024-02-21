import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/buttons/full_screen_button.dart';
import 'package:pregathi/db/db_services.dart';
import 'package:pregathi/model/contacts.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:sqflite/sqflite.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
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
        husbandPhoneNumber = userData['husbandPhone'];
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            goToDisableBack(context, BottomPage());
          },
        ),
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
                  itemCount: count + 2,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return buildFixedContactTile(
                        'Husband',
                        Icons.person,
                        index - 2,
                        husbandPhoneNumber,
                      );
                    } else if (index == 1) {
                      return buildFixedContactTile(
                        'Nearest Hospital',
                        Icons.local_hospital,
                        index - 2,
                        hospitalPhoneNumber,
                      );
                    } else {
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

  Widget buildFixedContactTile(
      String name, IconData icon, int index, String? phoneNumber) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(name),
          leading: Icon(icon),
          subtitle: Text('${phoneNumber}'),
          trailing: phoneNumber != null
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.13555,
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
                    ],
                  ),
                )
              : null,
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
                  width: MediaQuery.of(context).size.width * 0.27,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          deleteCon(contactList![index]);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
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
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
