import 'dart:developer';
import 'package:cattle_managementapp/pages/landing_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final isLoadingAuth = true.obs;
  final user = FirebaseAuth.instance.currentUser.obs;

  @override
  void onInit() {
    super.onInit();

    FirebaseAuth.instance.authStateChanges().listen((User? u) {
      user.value = u;
      if (u == null) {
        log('User is currently signed out!');
        isLoadingAuth.value = false;
        update();
      } else {
        log('User is signed in!');
        isLoadingAuth.value = false;
        update();
        Get.off(() => LandingPage());
      }
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    isLoadingAuth.value = true;
    update();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn().catchError((e, s) {
      log("There was an error signing in $e\n$s");
      isLoadingAuth.value = false;
      update();
      return null;
    });

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    isLoadingAuth.value = false;
    update();

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    bool? shouldSignOut = await showSignOutDialog();
    if (shouldSignOut ?? false) {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<bool?> showSignOutDialog() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
