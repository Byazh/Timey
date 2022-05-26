import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus/files/files.dart';
import 'package:focus/main.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var forceUpdate = false;

void checkUpdate() async {
  /// Only check one day and one not
  if (DateTime.now().day.isEven) return;
  final database = await FirebaseFirestore.instance.collection("general").doc("update").get();
  final latestVersion = database.get("latestVersion");
  final update = database.get("forceUpdate");
  if (latestVersion > version && version < database.get("minVersion")) {
    forceUpdate = update;
    UPDATE_FILE.write(jsonEncode({
      "latestVersion": latestVersion,
      "forceUpdate": update
    }));
  } else {
    forceUpdate = false;
    UPDATE_FILE.write(jsonEncode({
      "latestVersion": version,
      "forceUpdate": false
    }));
  }
}

bool openedUpdater = false;

void showUpdateDialog(BuildContext context) async {
  await Future.delayed(Duration(seconds: 2));
  showFadingDialog(
      context: context,
      builder: (context) {
        return CustomDialogBase(
            titleIcon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: height / 30,
            ),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: height / 40.5, left: width / 36, right: width / 36, bottom: height / 73),
                  child: Text(
                    AppLocalizations.of(context)!.updateTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: height / 45,
                        fontWeight: FontWeight.w600
                    ),),
                ),
                Padding(
                  padding: EdgeInsets.only(left: width / 24, right: width / 24, top: height / 244, bottom: width / 18),
                  child: Text(
                    AppLocalizations.of(context)!.updateSub,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: height / 52,
                        fontWeight: FontWeight.w400
                    ),),
                ),
                CustomButton(
                    text: "   ${AppLocalizations.of(context)!.update}   ",
                    onPressed: () async {
                      InAppReview.instance.openStoreListing(
                        /// TODO: Put the app store id
                        appStoreId: "com.focus.mobile"
                      );
                    }),
              ],
            )
        );
      },
      duration: Duration(milliseconds: 500)
  );
}