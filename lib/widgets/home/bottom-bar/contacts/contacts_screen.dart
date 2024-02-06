import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pregathi/db/db_services.dart';
import 'package:pregathi/main-screens/home-screen/wife_home_screen.dart';
import 'package:pregathi/model/contacts.dart';
import 'package:pregathi/const/constants.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  DatabaseService databaseHelper = DatabaseService();
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    askPermissions();
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

  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactsPermissions();
    if (permissionStatus == PermissionStatus.granted) {
      getFullContacts();
      searchController.addListener(() {
        filterContacts();
      });
    } else {
      handleInvalidPermissions(permissionStatus);
    }
  }

  handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      dialogueBox(context, 'Access to the contacts denied by the user');
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      dialogueBox(context, 'Access to the contacts permanently denied');
    }
  }

  Future<PermissionStatus> getContactsPermissions() async {
    PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
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
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              goTo(context, WifeHomeScreen());
            }),
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
                                title: Text(contact.displayName!),
                                //subtitle:
                                // Text(contact.phones!.elementAt(0).value!),
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
    Navigator.of(context).pop(true);
  }
}
