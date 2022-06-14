import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/models/todo.dart';
import 'package:planter_squared/data/models/user.dart';
import 'package:planter_squared/data/providers/auth_exceptions.dart';
import 'package:planter_squared/data/repos.dart';
import 'package:planter_squared/data/util/constants.dart';
import 'package:planter_squared/data/util/firebase_service.dart';

enum AuthStatus { uninitialized, authenticated, authenticating, unauthenticated }

class Authentication with ChangeNotifier {
  Authentication.instance()
      : _auth = FirebaseAuth.instance,
        _status = AuthStatus.uninitialized,
        _loading = true {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  final FirebaseAuth _auth;
  User? _firebaseUser;
  AuthUser? _authUser;
  AuthStatus _status;
  bool _loading;
  StreamSubscription? _userListener;
  Timer? _emailVerificationTimer;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  AuthUser? get authUser => _authUser;
  bool get isLoading => _loading;
  bool get _emailVerified => firebaseUser?.emailVerified ?? false;

  String? _nextName;
  set nextName(String n) => _nextName = n;

  Future signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw AuthExceptions.instance[e.code];
    }
  }

  Future signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw AuthExceptions.instance[e.code];
    }
  }

  Future sendVerificationEmail() async {
    await firebaseUser?.sendEmailVerification();
  }

  Future signOut() async {
    await _auth.signOut();
    _status = AuthStatus.unauthenticated;
    _firebaseUser = null;
    _authUser = null;
    _userListener?.cancel();
    _emailVerificationTimer?.cancel();
    notifyListeners();
  }

  Future _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _authUser = null;
    } else {
      _firebaseUser = firebaseUser;
      if (_emailVerified) {
        _emailVerificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
          await this.firebaseUser!.reload();
          _firebaseUser = _auth.currentUser;
          if (_emailVerified) {
            _status = AuthStatus.authenticated;
            _emailVerificationTimer?.cancel();
          }
          notifyListeners();
        });
      }
      _saveUser();
      _userListener = userDatabase.streamSingle(_firebaseUser!.uid).listen((user) {
        _authUser = user;
        _loading = false;
        notifyListeners();
      });
      _status = this.firebaseUser!.emailVerified ? AuthStatus.authenticated : AuthStatus.authenticating;
    }
    notifyListeners();
  }

  Future _saveUser() async {
    if (firebaseUser == null) return;
    AuthUser user = AuthUser(
        uid: firebaseUser!.uid,
        name: firebaseUser!.displayName ?? _nextName,
        email: firebaseUser!.email,
        planterDatabase: CloudDatabaseService(
          collection: '${DatabaseConstants.userCollection}/${firebaseUser!.uid}/${DatabaseConstants.planterCollection}',
          fromJson: Planter.load,
          toJson: (planter) => planter.json(),
        ),
        taskDatabase: CloudDatabaseService(
          collection: '${DatabaseConstants.userCollection}/${firebaseUser!.uid}/${DatabaseConstants.planterCollection}',
          fromJson: Task.load,
          toJson: (task) => task.json(),
        ));
    _nextName = null;
    AuthUser? existing = await userDatabase.fetchSingle(firebaseUser!.uid);
    if (existing == null) {
      await userDatabase.createEntry(user.json(), id: firebaseUser!.uid);
      _authUser = user;
    }
  }

  @override
  void dispose() {
    _userListener?.cancel();
    _emailVerificationTimer?.cancel();
    super.dispose();
  }
}
