import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void>? createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await _firebaseAuth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      FirebaseFirestore.instance.collection('user').doc(value.user!.uid).set({
        "email": value.user!.email,
        "id": value.user!.uid,
        'name': '',
        'complication': '',
        'childAge': '',
        'childGender': '',
        'isPregnant': true,
        'numberOfTimesPregnant': '',
        'parentType': '',
        'weight': '',
        'medicalHistory': FieldValue.arrayUnion([]),
        'notes': FieldValue.arrayUnion([])
      });
    });
    return null;
  }

  

  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}