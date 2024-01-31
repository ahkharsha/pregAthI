//import 'package:flutter/gestures.dart';
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
  const AddContactsScreen({super.key});

  @override
  State<AddContactsScreen> createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends State<AddContactsScreen> {
  DatabaseService _databaseHelper = DatabaseService();
  List<TContact>? contactList;
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

  deleteCon(TContact contact) async {
    int result = await _databaseHelper.deleteContact(contact.id);
    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact removed successfully..");
      listShow();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      listShow();
    });

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
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
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
                          ));
                      if (result == true) {
                        listShow();
                      }
                    }),
                Expanded(
                  child: ListView.builder(
                    itemCount: count,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(contactList![index].name),
                            trailing: Container(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        await FlutterPhoneDirectCaller.callNumber(
                                            contactList![index].number);
                                      },
                                      icon: Icon(
                                        Icons.call,
                                        color: Colors.red,
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        deleteCon(contactList![index]);
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            )),
      ),
    );
  }
}
