import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
  Future<void> changePassword(String password);
}

class Auth1 implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password)).user;
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }

  String email1;

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> changePassword(String password) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.updatePassword(password).then((_) {
      print("Succesfull changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
    });
    return null;
  }
}
