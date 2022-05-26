import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:focus/utils/data_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../auth/login_page.dart';

class SettingsOption extends StatelessWidget {

  final String title;
  final String subtitle;
  final bool first;
  final Function() onTap;

  const SettingsOption({Key? key, required this.title, required this.subtitle, this.first = false, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: width / 19, right: width / 19, top: first ? height / 18 : height / 40.6),
            child: ListTile(
              title: Text(
                title,
                style: TextStyle(
                    color: Color.fromRGBO(37, 76, 64, 0.85),
                    fontSize: height / 51,
                    fontWeight: FontWeight.w600
                ),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(
                    color: Color.fromRGBO(37, 76, 64, 0.6),
                    fontSize: height / 54,
                    fontWeight: FontWeight.w400
                ),
              ),
              trailing: Icon(
                  Icons.arrow_right,
                size: height / 28,
              ),
            ),
          ),
          if (title != "About") Container(
            width: width,
            color: Colors.black12,
            height: 1,
            margin: EdgeInsets.only(top: height / 36.6, left: width / 8.7, right: width / 9.8),
          )
        ],
      ),
    );
  }
}

class EmailSenderWidget extends StatelessWidget {

  final TextEditingController controller = TextEditingController();

   EmailSenderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialogBase(
        titleIcon: Icon(
          Icons.email,
          color: Colors.white,
          size: height / 21,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: height / 40.5, left: width / 18, right: width / 18, bottom: height / 73),
              child: Text(
                AppLocalizations.of(context)!.helpField,
                textAlign: TextAlign.center,
               style: TextStyle(
                color: Colors.black87,
                 fontSize: height / 50,
                 fontWeight: FontWeight.w600
              ),),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 18, vertical: height / 49),
                child: TextField(
                  controller: controller,
                    maxLines: 6,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.2),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(height / 36.0),
                            borderSide: BorderSide.none
                        )
                    )
                )
            ),
            CustomButton(
                text: AppLocalizations.of(context)!.send,
                onPressed: () async {
                  final Email email = Email(
                    body: controller.text,
                    subject: 'Assistance to ${getEmail(context)}',
                    recipients: ['focus.business.developer@gmail.com'],
                    isHTML: false,
                  );
                  await FlutterEmailSender.send(email);
                })
          ],
        )
    );
  }
}

class AboutPage extends StatelessWidget {

  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: Color.fromRGBO(37, 76, 64, 0.85),
      fontWeight: FontWeight.w600,
      fontSize: height / 49
    );
    final contentStyle = TextStyle(
        color: Color.fromRGBO(37, 76, 64, 0.5),
        fontWeight: FontWeight.w400,
        fontSize: height / 52
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height / 14.6),
        child: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: true,
            leading: GestureDetector(
                child: Icon(
                    Icons.arrow_back,
                    color: Color.fromRGBO(37, 76, 64, 0.85),
                    size: height / 35
                ),
                onTap: () {
                  Navigator.pop(context);
                }
            ),
            title: Text(
                AppLocalizations.of(context)!.about,
                style: TextStyle(
                    color: Color.fromRGBO(37, 76, 64, 0.85),
                    fontSize: height / 52.3,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500
                )
            )
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(height: height / 24.4),
          Text(
            AppLocalizations.of(context)!.about1,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          SizedBox(height: height / 73),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width / 12),
            child: Text(
              AppLocalizations.of(context)!.about1Sub,
              textAlign: TextAlign.center,
              style: contentStyle,
            ),
          ),
          SizedBox(height: height / 14.6),
          Text(
            AppLocalizations.of(context)!.about2,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          SizedBox(height: height / 73),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width / 12),
            child: Text(
              AppLocalizations.of(context)!.about2Sub,
              textAlign: TextAlign.center,
              style: contentStyle,
            ),
          ),
          SizedBox(height: height / 14.6),
          Text(
            AppLocalizations.of(context)!.about3,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          SizedBox(height: height / 73),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width / 12),
            child: Text(
              AppLocalizations.of(context)!.about3Sub,
              textAlign: TextAlign.center,
              style: contentStyle,
            ),
          ),
          SizedBox(height: height / 14.6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width / 25),
            child: Text(
              AppLocalizations.of(context)!.about4,
              textAlign: TextAlign.center,
              style: titleStyle,
            ),
          ),
          SizedBox(height: height / 73),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width / 12),
            child: Text(
              AppLocalizations.of(context)!.about4Sub,
              textAlign: TextAlign.center,
              style: contentStyle,
            ),
          ),
          SizedBox(height: height / 18),
        ],
      ),
    );
  }
}

class EditUsernameDialog extends StatelessWidget {

  final TextEditingController controller = TextEditingController();

  EditUsernameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialogBase(
        titleIcon: Icon(
          Icons.person,
          color: Colors.white,
          size: height / 21,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: height / 40, left: width / 39, right: width / 39, bottom: height / 73),
              child: Text(
                AppLocalizations.of(context)!.writeUsername,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: height / 50,
                    fontWeight: FontWeight.w600
                ),),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 48),
                child: CustomTextField(
                    controller: controller,
                  wrong: (text) {
                      if (text.length > 11) return true;
                      return false;
                  },
                  hintText: '',
                )
            ),
            CustomButton(
                text: AppLocalizations.of(context)!.save,
                onPressed: () async {
                  if (controller.text.length < 11) {
                    setUsername(controller.text);
                    FirebaseFirestore.instance.collection("users").doc(getEmail(context)).update({"username": controller.text});
                  }
                  Navigator.pop(context);
                })
          ],
        )
    );
  }
}

class UploadProfilePicturePopup extends StatelessWidget {

  const UploadProfilePicturePopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialogBase(
        titleIcon: Icon(
          Icons.image,
          color: Colors.white,
          size: height / 21,
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
                    AppLocalizations.of(context)!.uploadProfilePic,
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
                    AppLocalizations.of(context)!.uploadProfilePicSub,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: height / 52,
                        fontWeight: FontWeight.w400
                    )
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Color.fromRGBO(37, 76, 64, 1.0),
                        size: height / 26
                      ),
                      SizedBox(height: height  / 150),
                      Text(
                        AppLocalizations.of(context)!.camera,
                        style: TextStyle(
                          color: Color.fromRGBO(37, 76, 64, 1.0),
                          fontSize: height / 52
                        ),
                      )
                    ],
                  ),
                  onTap: () async {
                    try {
                      final image = File((await ImagePicker().pickImage(source: ImageSource.camera))!.path);
                      flutterLocalNotificationsPlugin.show(
                          1039492,
                          ":)",
                          AppLocalizations.of(context)!.profilePictureUpdating,
                          platformChannelSpecifics
                      );
                      Future.delayed(Duration(seconds: 1), () {
                        flutterLocalNotificationsPlugin.cancel(1039492);
                      });
                      showSnackBar(context, AppLocalizations.of(context)!.profilePictureUpdating, Color.fromRGBO(251, 246, 181, 1), Colors.black87);
                      final firebaseStorageRef = FirebaseStorage.instance.ref().child('profiles/${getEmail(context)}');
                      final uploadTask = await firebaseStorageRef.putFile(image);
                      final url = await uploadTask.ref.getDownloadURL();
                      FirebaseFirestore.instance
                      .collection("users")
                      .doc(getEmail(context))
                      .update({
                        "image": url
                      });
                      profilePic.value = url;
                      profilePic.notifyListeners();
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
                SizedBox(width: width / 8),
                GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        color: Color.fromRGBO(37, 76, 64, 1.0),
                        size: height / 25
                      ),
                      SizedBox(height: height / 150),
                      Text(
                        AppLocalizations.of(context)!.gallery,
                        style: TextStyle(
                          color: Color.fromRGBO(37, 76, 64, 1.0),
                          fontSize: height / 52
                        ),
                      )
                    ],
                  ),
                  onTap: () async {
                    try {
                      final image = File((await ImagePicker().pickImage(source: ImageSource.gallery))!.path);
                      flutterLocalNotificationsPlugin.show(
                          1039492,
                          ":)",
                          AppLocalizations.of(context)!.profilePictureUpdating,
                          platformChannelSpecifics
                      );
                      Future.delayed(Duration(seconds: 1), () {
                        flutterLocalNotificationsPlugin.cancel(1039492);
                      });
                      Navigator.pop(context);
                      final firebaseStorageRef = FirebaseStorage.instance.ref().child('profiles/${getEmail(context)}');
                      final uploadTask = await firebaseStorageRef.putFile(image);
                      final url = await uploadTask.ref.getDownloadURL();
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(getEmail(context))
                          .update({
                        "image": url
                      });
                      profilePic.value = url;
                      profilePic.notifyListeners();
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: height / 50)
          ],
        )
    );
  }
}


