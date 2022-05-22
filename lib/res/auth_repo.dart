import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planter_squared/model/auth_user.dart';
import 'package:planter_squared/res/auth_exceptions.dart';

typedef Json = Map<String, dynamic>;

class Auth extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthUser? _user;
  AuthUser get user => _user!;

  Stream<AuthUser?> get onAuthStateChanges =>
      _auth.authStateChanges().asyncMap(fetchUserData);

  Future<AuthUser?> fetchUserData(User? user) async {
    if (user == null) return null;

    DocumentSnapshot<Json> userSnapshot =
        await _firestore.collection('users').doc(user.uid).get();
    // TODO: may cause problems if user is deleted from storage but not from auth database
    AuthUser authUser = AuthUser.load(userSnapshot.data()!);
    _user = authUser;
    return authUser;
  }

  Future<void> refreshUserData() async {
    DocumentSnapshot<Json> userSnapshot =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    AuthUser authUser = AuthUser.load(userSnapshot.data()!);
    _user = authUser;
    notifyListeners();
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (authError) {
      throw AuthExceptions.instance[authError.code];
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
