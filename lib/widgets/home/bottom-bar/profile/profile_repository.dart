import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pregathi/failure.dart';
import 'package:pregathi/model/wife_profile.dart';
import 'package:pregathi/providers/firebase_providers.dart';
import 'package:pregathi/type_defs.dart';

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(firestore: ref.watch(firestoreProvider));
});

class ProfileRepository {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore;
  ProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

Stream<WifeProfile> getProfileByUid(String Uid) {
    return _users.doc(user!.uid).snapshots().map(
        (event) => WifeProfile.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editProfile(WifeProfile wife) async {
    try {
      return right(_users.doc(user!.uid).update(wife.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _users =>
      _firestore.collection('users');
}
