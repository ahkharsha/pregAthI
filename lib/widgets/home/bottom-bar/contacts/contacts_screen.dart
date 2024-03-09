import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/bottom-sheet/insta_share_bottom_sheet.dart';
import 'package:pregathi/buttons/full_screen_button.dart';
import 'package:pregathi/db/db_services.dart';
import 'package:pregathi/model/contacts.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/widgets/home/bottom-bar/contacts/add_contacts.dart';
import 'package:pregathi/widgets/home/bottom_page.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  DatabaseService _databaseHelper = DatabaseService();
  List<TContact>? contactList;
  String? husbandPhoneNumber = '';
  String? hospitalPhoneNumber = '';

  int count = 0;

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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            goToDisableBack(context, BottomPage());
          },
        ),
        title: Text(
          translation(context).trustedContacts,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return InstaShareBottomSheet();
              },
            );
          },
          backgroundColor: Colors.red,
          foregroundColor: boxColor,
          highlightElevation: 50,
          child: Icon(
            Icons.warning_outlined,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 2.h,
              ),
              FullScreenButton(
                title: translation(context).addTrustedContacts,
                onPressed: () async {
                  bool result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddContactsScreen(),
                    ),
                  );
                  if (result == true) {
                    listShow();
                  }
                },
              ),
              SizedBox(
                height: 3.h,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: count + 2,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return buildFixedContactTile(
                        translation(context).husband,
                        Icons.person,
                        index - 2,
                        husbandPhoneNumber,
                      );
                    } else if (index == 1) {
                      return buildFixedContactTile(
                        translation(context).nearestHospital,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Card(
        color: boxColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.black, width: 1),
        ),
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
      ),
    );
  }

  Widget buildContactTile(
      String name, IconData icon, int index, String? phoneNumber) {
    return Card(
      color: boxColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.black, width: 1),
      ),
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
