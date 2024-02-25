import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/auth/auth.dart';
import '/model/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel userProviderData = UserModel(
      id: '',
      name: '',
      email: '',
      complication: '',
      childAge: '',
      childGender: '',
      isPregnant: true,
      numOfTimesPregnant: '',
      parentType: '',
      dueDate: DateTime.now(),
      medicalHistory: [],
      notes: [],
      weight: '');

  Future<void> setUserName(String name) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"name": name});
    print('Done name');
  }

  Future<void> setIsPregnant(bool isPregnant) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"isPregnant": isPregnant});
    print('Done pregnant');
  }

  Future<void> setParentType(String parentType) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"parentType": parentType});
    print('Done type');
  }

  Future<void> setChildAge(String age) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"childAge": age});
    print('Done age');
  }

  Future<void> setChildGender(String gender) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"childGender": gender});
    print('Done gender');
  }

  Future<void> setNumberOfTimesPregnant(String numberOfTimesPregnant) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"numberOfTimesPregnant": numberOfTimesPregnant});
    print('Done num times');
  }

  Future<void> setComplication(String complication) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"complication": complication});
    print('Done usage');
  }

  Future<void> setMedicalHistory(String medHis) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"medicalHistory": medHis});
    print('Done medicalHistory');
  }

  Future<void> setWeight(double weight) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"weight": weight});
    print('Done weight');
  }

  Future<void> setNotes(String notes) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"notes": notes});
    print('Done notes');
  }

  Future<void> addNewNotes(List<String> notesList) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"notes": FieldValue.arrayUnion(notesList)});
    print('Added notes');
  }

  Future<void> addNewMedHis(List<String> medHis) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .update({"medicalHistory": FieldValue.arrayUnion(medHis)});
    print('Added medHis');
  }

  Future<void> fetchUserData() async {
    List<String> tempMedicalHistory = <String>[];
    List<String> tempNotes = <String>[];
    await FirebaseFirestore.instance
        .collection('user')
        .doc(Auth().currentUser!.uid)
        .get()
        .then(
      (snapshot) {
        userProviderData.id = snapshot.data()!['id'];
        userProviderData.name = snapshot.data()!['name'];
        userProviderData.email = snapshot.data()!['email'];
        userProviderData.complication = snapshot.data()!['complication'];
        userProviderData.childAge = snapshot.data()!['childAge'];
        userProviderData.childGender = snapshot.data()!['childGender'];
        userProviderData.numOfTimesPregnant =
            snapshot.data()!['numberOfTimesPregnant'];
        userProviderData.parentType = snapshot.data()!['parentType'];
        userProviderData.isPregnant = snapshot.data()!['isPregnant'];
        userProviderData.weight = snapshot.data()!['weight'];
        List.from(snapshot.data()!['medicalHistory']).forEach(
          (medHis) {
            String data = medHis;
            tempMedicalHistory.add(data);
          },
        );
        userProviderData.medicalHistory = tempMedicalHistory;
        List.from(snapshot.data()!['notes']).forEach(
          (notes) {
            String data = notes;
            tempNotes.add(data);
          },
        );
        userProviderData.notes = tempNotes;
      },
    );
  }
}