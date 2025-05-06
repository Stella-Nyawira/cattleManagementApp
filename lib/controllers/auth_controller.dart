import 'dart:developer';

import 'package:cattle_managementapp/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        Get.off(() => Homepage());
      }
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    isLoadingAuth.value = true;
    update();
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn().catchError((e, s) {
      log("There was an error signing in $e\n$s");
      isLoadingAuth.value = false;
      update();
      return null;
    });

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    isLoadingAuth.value = false;
    update();

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}
