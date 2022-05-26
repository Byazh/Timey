import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:focus/files/files.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/pages/sounds/sounds_page_widgets.dart';
import 'package:focus/utils/coins_utilities.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:focus/utils/notifications_utils.dart';

import '../../main.dart';
import 'package:focus/pages/home/home_page_widgets.dart';

import 'package:focus/utils/multi_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/data_utils.dart';
import '../forest/forest_page.dart';

/// This class represents the login page

class LoginPage extends StatefulWidget {

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

/// This class represents the state of the above widget

class _LoginPageState extends State<LoginPage> {

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
          /// App logo
          Image.asset(
            "resources/images/logo.png",
            height: height / 10
          ),
          /// The email and password text fields
          Padding(
            padding: EdgeInsets.only(
                left: width / 13,
                right: width / 13,
                top: height / 18,
                bottom: height / 36
            ),
            child: _LoginForms()
          )
        ]
      )
    );
  }
}

/// This controller handles the email text field

final emailController = TextEditingController();

/// This controller handles the password text field

final passwordController = TextEditingController();

/// This class represents the widget containing the email and password text fields

class _LoginForms extends StatefulWidget {

  @override
  _LoginFormsState createState() => _LoginFormsState();
}

/// This class represents the state of the above widget

class _LoginFormsState extends State<_LoginForms> {

  final key = GlobalKey<FormState>();
  var loading = false;

  @override
  Widget build(BuildContext context) {
    final resetController = TextEditingController();
    return Form(
      key: key,
      child: Column(
        children: [
          /// Email text field
          CustomTextField(
            controller: emailController,
            wrong: (value) {
              if (value.isEmpty || !value.contains("@") || !value.contains(".")) {
                return true;
              }
              return false;
              },
              hintText: "   ${AppLocalizations.of(context)!.enterYourEmail}"
            ),
            SizedBox(height: height / 36),
            /// Password text field
            CustomTextField(
              controller: passwordController,
              password: true,
              wrong: (value) {
                if (value.isEmpty || value.length < 6) {
                  return true;
                }
                return false;
              },
              hintText: "   ${AppLocalizations.of(context)!.enterYourPassword}"
            ),
            SizedBox(height: height / 50),
            /// Reset password
            GestureDetector(
              child: Text(
                AppLocalizations.of(context)!.forgotYourPassword,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: height / 56
                )
              ),
              onTap: () {
                /// If email is valid, then send him the password reset email
                showFadingDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return CustomDialogBase(
                      titleIcon: Icon(
                        Icons.vpn_key,
                        color: Colors.white,
                        size: height / 25,
                      ),
                      body: Column(
                        children: [
                          SizedBox(height: height / 30),
                          Text(
                            AppLocalizations.of(context)!.passwordResetTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: height / 45,
                              fontWeight: FontWeight.w600
                            )
                          ),
                          SizedBox(height: height / 50),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width / 20),
                            child: Text(
                              AppLocalizations.of(context)!.passwordResetSub,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: height / 52,
                                fontWeight: FontWeight.w400
                              )
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: width / 19,
                              right: width / 19,
                              top: height / 33
                            ),
                            child: CustomTextField(
                              controller: resetController,
                              hintText: AppLocalizations.of(context)!.passwordResetHint,
                              wrong: (email) {
                                if (email.isEmpty || !email.contains("@") || !email.contains(".")) {
                                  return true;
                                }
                                return false;
                              }
                            )
                          ),
                          SizedBox(height: height / 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                text: " ${AppLocalizations.of(context)!.cancel} ",
                                color: Color.fromRGBO(210, 210, 210, 1.0),
                                onPressed: () {
                                  Navigator.pop(context);
                                }
                              ),
                              SizedBox(width: width / 15),
                              CustomButton(
                                text: " ${AppLocalizations.of(context)!.send} ",
                                onPressed: () async {
                                  await FirebaseAuth.instance.sendPasswordResetEmail(email: resetController.text);
                                  showSnackBar(context, AppLocalizations.of(context)!.emailInstructions);
                                  Navigator.of(context).pop();
                                }
                              )
                            ]
                          ),
                          SizedBox(height: height / 150)
                        ]
                      )
                    );
                  },
                  duration: Duration(milliseconds: 500)
                );
              }
            ),
            /// Login button
            Padding(
              padding: EdgeInsets.symmetric(vertical: height / 45),
              child: CustomButton(
                text: AppLocalizations.of(context)!.login,
                textSize: height / 45,
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
            /// Social auth buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (Platform.isAndroid)...[
                  GestureDetector(
                      child: CircleAvatar(
                          radius: height / 33,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            "resources/images/login/google.png",
                            height: height / 33,
                          )
                      ),
                      onTap: () => signWithGoogle(context, false)
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
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
        );
        final a = await FirebaseFirestore.instance.collection("users").doc(getEmail(context)).get();
        if (a.exists) {
          username.value = a.get("username");
          realTrees = a.get("realTrees");
          plantsUnlocked = a.get("plants").cast<String>();
          soundsUnlocked = a.get("sounds").cast<String>();
          PROFILE_FILE.write(jsonEncode({
            "email": FirebaseAuth.instance.currentUser?.email,
            "lastEdit": lastEdit,
            "username": username.value,
            "coins": coins,
            "realTrees": realTrees,
            "plants": plantsUnlocked,
            "sounds": soundsUnlocked,
            "lang": locale.value.languageCode,
            "lastDataUpdate": lastDataUpdate
          }));
        }
        Navigator.pushNamed(context, "/splash");
      } catch (e) {
        print(e);
        if(e is FirebaseAuthException) {
         showSnackBar(context, AppLocalizations.of(context)!.incorrectCredentials);
          setState(() {
            loading = false;
          });
        }
      }
    }
  }
}

/// This class represents a custom text field

class CustomTextField extends StatefulWidget {

  final TextEditingController controller;
  final bool password;
  final String hintText;
  final bool Function(String) wrong;

  const CustomTextField({
    required this.wrong,
    required this.controller,
    required this.hintText,
    this.password = false
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

/// This class represents the state of the above widget

class _CustomTextFieldState extends State<CustomTextField> {

  bool wrong = false;

  @override
  Widget build(BuildContext context) {
    void _checkValid(String value) {
      if (widget.wrong(value)) {
        setState(() {
          wrong = true;
        });
      } else {
        setState(() {
          wrong = false;
        });
      }
    }
    return TextFormField(
      validator: (value) {
        if (wrong) {
          return AppLocalizations.of(context)!.invalid;
        }
        return null;
      },
        obscureText: widget.password,
      onSaved: (value) {
        _checkValid(value!);
      },
      onChanged: (value) {
        _checkValid(value);
      },
      controller: widget.controller,
      maxLines: 1,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(height / 36),
          borderSide: BorderSide.none
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: height / 56,
          color: Colors.black54
        )
      )
    );
  }
}
