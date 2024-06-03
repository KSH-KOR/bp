import 'dart:async';
import 'dart:developer';

import 'package:bp/service/firestore/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../model/user.dart';

class AppAuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AppUser? _user;
  StreamSubscription<User?>? _authStateSubscription;

  AppUser? get user => _user;

  // if firebaseUser is null, the app will nagivate to signin page.
  // if firebaseUser is changed, a route will remain as it is but redraw the ui with the changed authuser model by notifying listeners.
  void syncAuthStateChanges() {
    _authStateSubscription ??=
        _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        _user = null;
        notifyListeners();
      } else {
        fetchAppUser(firebaseUser);
      }
    });
    log("syncAuthStateChanges: ${_authStateSubscription != null}");
  }

  Future<void> fetchAppUser(User firebaseUser) async {
    _user = await FirestoreService().getUser(firebaseUser);
    notifyListeners(); // notify listener so that ui can be refreshed with updated user data.
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
