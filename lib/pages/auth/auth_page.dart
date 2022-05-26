import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/utils/data_utils.dart';

import '../../files/files.dart';
import '../../main.dart';
import 'package:focus/pages/home/home_page_widgets.dart';

import 'package:focus/utils/dialog_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/coins_utilities.dart';
import '../forest/forest_page.dart';
import '../sounds/sounds_page_widgets.dart';

/// This class represents the authentication page

class AuthPage extends StatelessWidget {

  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: width / 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height / 25),
            /// Title
            Text(
              AppLocalizations.of(context)!.syncDevices,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(44, 106, 85, 1.0),
                fontSize: height / 30,
                fontWeight: FontWeight.w700
              )
            ),
            /// Main image
            Image.asset(
              "resources/images/welcome/login.png",
              height: height / 2
            ),
            /// Three buttons to register, login or continue as guest
            Column(
              children: [
                CustomButton(
                  text: AppLocalizations.of(context)!.register,
                  textSize: height / 45,
                  onPressed: () => Navigator.pushNamed(context, "/signup")
                ),
                SizedBox(height: height / 75),
                CustomButton(
                  text: AppLocalizations.of(context)!.login,
                  textSize: height / 45,
                  onPressed: () =>Navigator.pushNamed(context, "/login")
                ),
                SizedBox(height: height / 40),
                GestureDetector(
                  child: Text(
                    AppLocalizations.of(context)!.continueAsGuest,
                    style: TextStyle(
                      fontSize: height / 55,
                      color: Color.fromRGBO(37, 76, 64, 1.0)
                    )
                  ),
                  onTap: () => showGuestConfirmationPopup(context)
                ),
                SizedBox(height: height / 35)
              ]
            )
          ]
        ),
      )
    );
  }
}

/// This method opens a dialog to confirm the will to proceed as a guest

void showGuestConfirmationPopup(BuildContext context) =>
  showFadingDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => CustomDialogBase(
      titleIcon: Icon(
        Icons.sync_problem,
        color: Colors.white,
        size: height / 25
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: width / 50,
                right: width / 50,
                top: height / 24.5,
                bottom: height / 90
            ),
            child: Text(
              AppLocalizations.of(context)!.continueAsGuestWarning,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: height / 46,
                fontWeight: FontWeight.w600
              )
            )
          ),
          Padding(
            padding: EdgeInsets.only(
                left: width / 26,
                right: width / 26,
                top: height / 250,
                bottom: height / 36
            ),
            child: Text(
              AppLocalizations.of(context)!.continueAsGuestWarningSub,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: height / 52,
                fontWeight: FontWeight.w400
              )
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: AppLocalizations.of(context)!.cancel,
                color: Colors.grey.withOpacity(0.5),
                onPressed: () => Navigator.pop(context),
              ),
              _ConfirmGuestButton()
            ]
          ),
          SizedBox(height: height / 100)
      ]
    )
  ),
  duration: Duration(milliseconds: 500)
);

/// This class represents an async button that handles the user registration as guest

class _ConfirmGuestButton extends StatefulWidget {

  const _ConfirmGuestButton({Key? key}) : super(key: key);

  @override
  _ConfirmGuestButtonState createState() => _ConfirmGuestButtonState();
}

/// This class represents the state of the above widget

class _ConfirmGuestButtonState extends State<_ConfirmGuestButton> {

  var loading = false;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: AppLocalizations.of(context)!.confirm,
      loading: loading,
      onPressed: () async {
        setState(() {
          loading = true;
        });
        final email = generateRandomEmail();
        await FirebaseFirestore.instance.collection("users").doc(email).set({
          "username": "Guest",
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
          /// If it takes too long
        }).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              setState(() {
                loading = false;
              });
              flutterLocalNotificationsPlugin.show(
                1111,
                AppLocalizations.of(context)!.connectionProblemTitle,
                AppLocalizations.of(context)!.connectionProblemSub,
                platformChannelSpecifics
              );
          })
          /// If it's successful
        .whenComplete(() async {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: generateRandomPassword()
          );
          username.value = "Guest";
          plantsUnlocked = ["basic"];
          soundsUnlocked = ["rain"];
          PROFILE_FILE.write(jsonEncode({
            "email": FirebaseAuth.instance.currentUser?.email,
            "lastEdit": lastEdit,
            "username": "Guest",
            "coins": coins,
            "realTrees": 0,
            "plants": ["basic"],
            "sounds": ["rain"],
            "lang": locale.value.languageCode,
            "lastDataUpdate": lastDataUpdate
          }));
          Navigator.pushReplacementNamed(context, "/splash");
        });
      });
  }
}


