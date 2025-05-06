import 'dart:developer';

import 'package:cattle_managementapp/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/instance_manager.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder(
        init: Get.find<AuthController>(),
        builder: (authController) {
          return Center(
            child:
                authController.isLoadingAuth.value
                    ? SpinKitCircle(color: Colors.amber, size: 42)
                    : SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 21),
                          Column(
                            children: [
                              Text(
                                'Welcome to the Cattle Manager App',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                              ),
                              /*  Text(
                                'by Stella',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FontStyle.italic,
                                ),
                              ), */
                            ],
                          ),
                          Spacer(),
                          Text("Sign In", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
                          SignInButton(
                            Buttons.google,
                            onPressed: () async {
                              log("Want to sign in with google");

                              authController.signInWithGoogle().then((value) {
                                log("Signed in with google as ${value.user?.displayName}");
                                // Get.off(() => HomePage());
                              });
                              log("Yay 2");
                            },
                          ),
                          Spacer(),
                          SizedBox(height: 80),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }
}
