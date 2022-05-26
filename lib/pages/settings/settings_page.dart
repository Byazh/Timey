import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus/pages/forest/forest_page.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/pages/settings/settings_page_widgets.dart';
import 'package:focus/pages/sounds/sounds_page_widgets.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:focus/utils/lang_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share/share.dart';

import '../../files/files.dart';
import '../../main.dart';
import '../../utils/coins_utilities.dart';
import '../../utils/data_utils.dart';
import '../../utils/image_utils.dart';
import '../../utils/messages_utils.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  /// The body of the page
  late Widget body;
  /// The controller of the list view
  final controller = ScrollController();
  /// The background color
  var color = Color.fromRGBO(80, 163, 135, 1.0);

  var _selectedBreak = 0;

  @override
  void initState() {
    body = Builder(
      builder: (context) {
        return ListView(
            controller: controller,
            physics: BouncingScrollPhysics(),
            children: [
              Column(
                children: [
                  SizedBox(height: height / 50),
                  Container(
                    color: Color.fromRGBO(80, 163, 135, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: width / 7.5,
                          child: GestureDetector(
                            onTap: () {
                              showFadingDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) => EditUsernameDialog(),
                                  duration: Duration(milliseconds: 500)
                              );
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Color.fromRGBO(251, 246, 181, 1),
                                  size: height / 30,
                                ),
                                SizedBox(height: height / 146),
                                Text(
                                  AppLocalizations.of(context)!.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: height / 54
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: height / 146),
                            GestureDetector(
                              child: CircleAvatar(
                                radius: height / 18.3,
                                backgroundColor: Color.fromRGBO(251, 246, 181, 1),
                                child: FutureBuilder(
                                  future: () async {
                                    if (!profilePicLoaded) {
                                      profilePicLoaded = true;
                                      final a = await FirebaseFirestore.instance.collection("users").doc(getEmail(context)).get();
                                      profilePic.value = a.get("image");
                                      return a;
                                    }
                                    return Future.value(profilePic.value);
                                  }(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      String image = profilePic.value;
                                      if (image == "") {
                                        return Icon(
                                          Icons.camera_alt,
                                          color: Color.fromRGBO(80, 163, 135, 1),
                                          size: height / 21,
                                        );
                                      } else {
                                        return ValueListenableBuilder<String>(
                                          valueListenable: profilePic,
                                          builder: (context, value, child) {
                                            return ClipOval(
                                                child: FadeInImage.memoryNetwork(
                                                  placeholder: kTransparentImage,
                                                  image: value,
                                                  fit: BoxFit.cover,
                                                  height: height,
                                                  width: width
                                                )
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      return CupertinoActivityIndicator();
                                    }
                                  },
                                ),
                              ),
                              onTap: () {
                                showFadingDialog(
                                    context: context,
                                    builder: (context) => UploadProfilePicturePopup(),
                                    barrierDismissible: true,
                                    duration: Duration(milliseconds: 500)
                                );
                              },
                            ),
                            SizedBox(height: height / 48.8),
                            Container(
                              width: width / 2,
                              child: Text(
                                "${getEmail(context)}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: height / 52
                                ),
                              ),
                            ),
                            ValueListenableBuilder<String>(
                              valueListenable: username,
                              builder: (context, value, child) {
                                return Container(
                                  width: height / 9,
                                  child: Text(
                                    value,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: height / 54
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Container(
                          width: width / 7.5,
                          child: GestureDetector(
                            onTap: () {
                              showFadingDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) {
                                    return CustomDialogBase(
                                        titleIcon: Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: height / 21,
                                        ),
                                        body: Column(
                                          children: [
                                            SizedBox(height: height / 60,),
                                            Padding(
                                              padding: EdgeInsets.only(left: width / 45, right: width / 45, top: height / 24.4, bottom: height / 146),
                                              child: Text(
                                                AppLocalizations.of(context)!.confirmLogoutTitle,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: height / 48,
                                                    fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: width / 20, right: width / 20, top: height / 150, bottom: height / 75),
                                              child: Text(
                                                AppLocalizations.of(context)!.confirmLogoutSub,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: height / 52,
                                                    fontWeight: FontWeight.w400
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: height / 100,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                CustomButton(
                                                    text: AppLocalizations.of(context)!.cancel,
                                                    color: Colors.grey.withOpacity(0.5),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    }),
                                                CustomButton(
                                                    text: AppLocalizations.of(context)!.confirm,
                                                    color: Colors.red,
                                                    onPressed: () async {
                                                      Future.delayed(Duration(milliseconds: 100), () => Navigator.pushReplacementNamed(context, "/auth"));
                                                      var em = getEmail(context);
                                                      FirebaseMessaging.instance.unsubscribeFromTopic(topicEmail(getEmail(context)));
                                                      if (em!.contains("@focus.com")) {
                                                        FirebaseAuth.instance.currentUser!.delete();
                                                        await FirebaseFirestore.instance.collection("users").doc(em).delete();
                                                      }
                                                      await FirebaseAuth.instance.signOut();
                                                    })
                                              ],
                                            ),
                                            SizedBox(height: height / 60,),
                                          ],
                                        )
                                    );
                                  },
                                  duration: Duration(milliseconds: 500)
                              );
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Color.fromRGBO(251, 246, 181, 1),
                                  size: height / 30,
                                ),
                                SizedBox(height: height / 146),
                                Text(
                                  AppLocalizations.of(context)!.logout,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: height / 54
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Stack(
                children: [
                  Container(width: width, height: height * 0.85, color: Color.fromRGBO(80, 163, 135, 1)),
                  Container(
                    width: width,
                    height: height * 0.88,
                    margin: EdgeInsets.only(top: height / 29),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 250, 192, 1.0),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(height / 21))
                    ),
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        SettingsOption(
                          title: AppLocalizations.of(context)!.language,
                          subtitle: AppLocalizations.of(context)!.languageSub,
                          first: true,
                          onTap: () {
                            showFadingDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return CustomDialogBase(
                                    titleIcon: Icon(
                                      Icons.language,
                                      color: Colors.white,
                                      size: height / 21,
                                    ),
                                    body: Column(
                                      children: [
                                        Container(
                                          height: height / 5.5,
                                          child: CupertinoPicker(
                                            scrollController: FixedExtentScrollController(initialItem: locales.indexOf(locale.value)),
                                            onSelectedItemChanged: (int value) {
                                              _selectedBreak = value;
                                            },
                                            itemExtent: height / 16.2,

                                            children: [
                                              ...List.generate(5, (index) {
                                                return Column(
                                                  children: [
                                                    SizedBox(height: height / 61),
                                                    Text(
                                                      "${languages.keys.elementAt(index)}",
                                                      style: TextStyle(
                                                          color: Colors.black45,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: height / 44
                                                      ),
                                                    ),
                                                    SizedBox(height: height / 104)
                                                  ],
                                                );
                                              })
                                            ],
                                          ),
                                        ),
                                        CustomButton(text: AppLocalizations.of(context)!.save, onPressed: () {
                                          locale.value = locales[_selectedBreak];
                                          PROFILE_FILE.write(jsonEncode({
                                            "email": FirebaseAuth.instance.currentUser?.email,
                                            "lastEdit": lastEdit,
                                            "coins": coins,
                                            "username": username.value,
                                            "realTrees": realTrees,
                                            "plants": plantsUnlocked,
                                            "sounds": soundsUnlocked,
                                            "lang": locale.value.languageCode,
                                            "lastDataUpdate": lastDataUpdate
                                          }));
                                          Navigator.pop(context);
                                        })
                                      ],
                                    ),
                                  );
                                },
                                duration: Duration(milliseconds: 500)
                            );
                          },
                        ),
                        SettingsOption(
                          title: AppLocalizations.of(context)!.realTrees,
                          subtitle: AppLocalizations.of(context)!.realTreesSub,
                          onTap: () {
                            Navigator.pushNamed(context, "6");
                          },
                        ),
                        SettingsOption(
                          title: AppLocalizations.of(context)!.share,
                          subtitle: AppLocalizations.of(context)!.shareSub,
                          onTap: () {
                            Share.share("Hey!\nYou should really download this app!\n\n${Platform.isIOS ? "https://apps.apple.com/app/timey-focus-timer/id1617516028" : "https://play.google.com/store/apps/details?id=com.focus.mobile.focus"}");
                          },
                        ),
                        SettingsOption(
                          title: AppLocalizations.of(context)!.feedback,
                          subtitle: AppLocalizations.of(context)!.feedbackSub,
                          onTap: () async {
                            if (await InAppReview.instance.isAvailable()) {
                              InAppReview.instance.requestReview();
                            }
                          },
                        ),
                        SettingsOption(
                          title: AppLocalizations.of(context)!.help,
                          subtitle: AppLocalizations.of(context)!.helpSub,
                          onTap: (){
                            showFadingDialog(context: context, barrierDismissible: true, builder: (_) => EmailSenderWidget(), duration: Duration(milliseconds: 500));
                          },
                        ),
                        SettingsOption(
                          title: AppLocalizations.of(context)!.about,
                          subtitle: AppLocalizations.of(context)!.aboutSub,
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AboutPage()));
                          },
                        )
                      ],
                    ),
                  ),
                ],
              )
            ]
        );
      },
    );
    controller.addListener(_listener);
    super.initState();
  }

  /// This method handles the scrolling so that colors don't fuck up because of the
  /// bouncing scroll physics

  void _listener() {
    if (controller.offset < height * 0.03 && color == Color.fromRGBO(255, 250, 192, 1.0)) {
      setState(() {
        color = Color.fromRGBO(80, 163, 135, 1.0);
      });
    }
    if (controller.offset > height * 0.18 && color == Color.fromRGBO(80, 163, 135, 1.0)) {
      setState(() {
        color = Color.fromRGBO(255, 250, 192, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(height / 14.6),
          child: AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              elevation: 0,
              centerTitle: true,
              leading: Padding(
                padding: EdgeInsets.only(top: height / 60),
                child: GestureDetector(
                    child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: height / 35
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    }
                ),
              ),
              title: Padding(
                padding: EdgeInsets.only(top: height / 60),
                child: Text(
                    AppLocalizations.of(context)!.settings,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: height / 52.3,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500
                    )
                ),
              )
          ),
        ),
        body: body
    );
  }
}


