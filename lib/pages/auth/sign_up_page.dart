import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:focus/utils/notifications_utils.dart';

import '../../main.dart';
import 'package:focus/pages/home/home_page_widgets.dart';

import 'package:focus/utils/multi_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'login_page.dart';

/// This class represents the sign up page

class SignUpPage extends StatefulWidget {

  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

/// This class represents the state of the above widget

class _SignUpPageState extends State<SignUpPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height / 14.6),
        child: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            child: Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(37, 76, 64, 1.0),
              size: height / 35
            ),
            onTap: () => Navigator.pop(context)
          )
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "resources/images/logo.png",
            height: height / 10,
          ),
          Padding(
            padding: EdgeInsets.only(
                left: width / 13,
                right: width / 13,
                top: height / 18,
                bottom: height / 19
            ),
            child: _SignUpForm()
          )
        ]
      )
    );
  }
}

/// This class represents the widget containing the username, email and password fields

class _SignUpForm extends StatefulWidget {

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

/// This is the controller of the username text field

final usernameController = TextEditingController();

/// This is the controller of the email text field

final emailController = TextEditingController();

/// This is the controller of the password text field

final passwordController = TextEditingController();

/// This class represents the state of the above widget

class _SignUpFormState extends State<_SignUpForm> {

  final key = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Column(
        children: [
          CustomTextField(
            controller: usernameController,
            hintText: AppLocalizations.of(context)!.chooseUsername,
            wrong: (value) {
              if (value.isEmpty) {
                return true;
              }
              return false;
            }
          ),
          SizedBox(height: height / 36),
          CustomTextField(
            controller: emailController,
            hintText: AppLocalizations.of(context)!.enterYourEmail,
            wrong: (value) {
              if (value.isEmpty || !value.contains("@")) {
                return true;
              }
              return false;
            }
          ),
          SizedBox(height: height / 36),
          CustomTextField(
            controller: passwordController,
            password: true,
            hintText: AppLocalizations.of(context)!.enterYourPassword,
            wrong: (value) {
              if (value.isEmpty || value.length < 6) {
                return true;
              }
              return false;
            }
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: height / 36),
            child: CustomButton(
              text: "  ${AppLocalizations.of(context)!.enter}  ",
              textSize: height / 40,
              loading: loading,
              onPressed: () {
                setState(() {
                  loading = true;
                  key.currentState!.save();
                  _checkCode();
                });
              }
            )
          ),
          Text(
            AppLocalizations.of(context)!.orSignInWith,
            style: TextStyle(
              color: Colors.black54,
              fontSize: height / 56
            )
          ),
          SizedBox(height: height / 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (Platform.isAndroid)...[
                GestureDetector(
                    child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          "resources/images/login/google.png",
                          height: 20,
                        )
                    ),
                    onTap: () => signWithGoogle(context, true)
                )
              ],
              if (Platform.isIOS)...[
                GestureDetector(
                  child: CircleAvatar(
                    radius: height / 33,
                    backgroundColor: Colors.black87,
                    child: Image.asset(
                      "resources/images/login/apple.png",
                      height: height / 24.5
                    )
                  ),
                    onTap: () => signInWithApple(context, false)
                )
              ]
            ]
          )
        ]
      )
    );
  }

  /// This method handles the authentication

  void _checkCode() async {
    if (key.currentState!.validate()) {
      try {
        final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );
        await user.user!.sendEmailVerification();
        FirebaseFirestore.instance.collection("users").doc(user.user!.email).set({
          "username": usernameController.text,
          "image": "",
          "success": 0,
          "failures": 0,
          "minutes": 0,
          "friends": [],
          "received": [],
          "sent": [],
          "premium": false,
          "realTrees": 0,
          "plants": ["basic"],
          "sounds": ["rain"]
        });
        Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context, _, __) => ConfirmEmailPage()));
      } catch (e) {
        if(e is FirebaseAuthException ) {
          if(e.code == 'email-already-in-use') {
            setState(() {
              loading = false;
            });
            showSnackBar(context, AppLocalizations.of(context)!.emailAlreadyExisting);
          }
        }
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }
}

/// This class represents the page that awaits for the user to confirm his email

class ConfirmEmailPage extends StatefulWidget {

  const ConfirmEmailPage({Key? key}) : super(key: key);

  @override
  _ConfirmEmailPageState createState() => _ConfirmEmailPageState();
}

/// This class represents the state of the above widget

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    Future(() async {
      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        var user = FirebaseAuth.instance.currentUser;
        if (user!.emailVerified) {
          Navigator.pushNamed(context, "/splash");
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(height / 14.6),
          child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GestureDetector(
                  child: Icon(
                      Icons.arrow_back,
                      color: Color.fromRGBO(37, 76, 64, 1.0),
                      size: height / 35
                  ),
                  onTap: () => Navigator.pop(context)
              )
          ),
        ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: width / 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.verifyEmail,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: height / 35
                ),
              ),
              SizedBox(height: height / 49),
              Text(
                AppLocalizations.of(context)!.verifyEmailSub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height / 45,
                  fontWeight: FontWeight.w400
                )
              )
            ]
          )
        )
      )
    );
  }
}
