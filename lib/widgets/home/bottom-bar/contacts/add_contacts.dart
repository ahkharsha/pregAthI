import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/db/db_services.dart';
import 'package:pregathi/model/contacts.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/navigators.dart';

class AddContactsScreen extends StatefulWidget {
  const AddContactsScreen({super.key});

  @override
  State<AddContactsScreen> createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends State<AddContactsScreen> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  DatabaseService databaseHelper = DatabaseService();
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((element) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = element.displayName!.toLowerCase();
        bool nameMatch = contactName.contains(searchTerm);
        if (nameMatch == true) {
          return true;
        }
        if (searchTermFlatten.isEmpty) {
          return false;
        }
        var phone = element.phones!.firstWhere((p) {
          String phnFlattened = flattenPhoneNumber(p.value!);
          return phnFlattened.contains(searchTermFlatten);
        });
        return phone.value != null;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  fetchContacts() {
    getFullContacts();
      searchController.addListener(() {
        filterContacts();
      });
  }

  getFullContacts() async {
    List<Contact> _contacts =
        await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    bool listItemExit = (contactsFiltered.length > 0 || contacts.length > 0);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
            onPressed: () => goBack(context)),
        title: Text(
          "Add Contacts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      body: contacts.length == 0
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autofocus: true,
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "Search Contact",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  listItemExit == true
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: isSearching == true
                                ? contactsFiltered.length
                                : contacts.length,
                            itemBuilder: (BuildContext context, int index) {
                              Contact contact = isSearching == true
                                  ? contactsFiltered[index]
                                  : contacts[index];
                              return ListTile(
                                title: Text(contact.displayName??'Phone contact ${index+1}'),
                                // subtitle:
                                //     Text(contact.phones!.elementAt(0).value!),
                                leading: contact.avatar != null &&
                                        contact.avatar!.length > 0
                                    ? CircleAvatar(
                                        backgroundColor: primaryColor,
                                        backgroundImage:
                                            MemoryImage(contact.avatar!),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: primaryColor,
                                        child: Text(contact.initials()),
                                      ),
                                onTap: () {
                                  if (contact.phones!.length > 0) {
                                    final String phoneNumber =
                                        contact.phones!.elementAt(0).value!;
                                    final String Name = contact.displayName!;
                                    _addContact(TContact(phoneNumber, Name));
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Phone number does not exist..");
                                  }
                                },
                              );
                            },
                          ),
                        )
                      : Container(
                          child: Text("searching"),
                        ),
                ],
              ),
            ),
    );
  }

  void _addContact(TContact newContact) async {
    int result = await databaseHelper.insertContact(newContact);
    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact added succesfully!");
    } else {
      Fluttertoast.showToast(msg: "Failed to add contact..");
    }
    goBack(context);
  }
}
