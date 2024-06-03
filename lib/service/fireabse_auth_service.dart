import 'dart:developer';

import 'package:bp/constant/message/error_msg.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:bp/service/firestore/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'exceptions/custom_exception.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Login
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        log("signInWithGoogle(): googleUser is null");
        throw Exception(ErrorMsg.loginFailed);
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // firebase auth listener will handle next event.
      await _firebaseAuth.signInWithCredential(credential);
    } catch (error) {
      log("signInWithGoogle(): $error");
      throw CustomException(ErrorMsg.loginFailed);
    }
  }

  // Email & Password Login
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      // firebase auth listener will handle next event.
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      log("signInWithEmailPassword(): $error");
      throw CustomException(ErrorMsg.loginFailed);
    }
  }

  // Logout
  Future<void> signOut(BuildContext context) async {
    try {
      Provider.of<PlaceProvider>(context, listen: false).reset();
      Navigator.of(context).popUntil((route) => route.isFirst);
      await _googleSignIn
          .signOut(); // Optional: if you want to disconnect the Google account entirely
      await _firebaseAuth.signOut();
    } catch (error) {
      log("signOut(): $error");
      throw CustomException(ErrorMsg.logoutFailed);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception();

      Provider.of<PlaceProvider>(context, listen: false).reset();
      Navigator.of(context).popUntil((route) => route.isFirst);
      await FirestoreService().deleteAllMyPlace(user.uid);
      await _googleSignIn
          .disconnect(); // Optional: if you want to disconnect the Google account entirely

      await _firebaseAuth.currentUser?.delete();
    } catch (error) {
      log("signOut(): $error");
      throw CustomException(ErrorMsg.logoutFailed);
    }
  }
}
