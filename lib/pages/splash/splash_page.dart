import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:focus/main.dart';
import 'package:focus/models/models.dart';
import 'package:focus/pages/home/home_page.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/pages/welcome/welcome_page.dart';
import 'package:focus/utils/data_utils.dart';
import 'package:focus/utils/messages_utils.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:provider/provider.dart';

import '../../utils/multi_utils.dart';
import '../../utils/timer_utils.dart';

/// This class represents the splash page that appears when the application is
/// opened

class SplashPage extends StatefulWidget {

  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

/// This class represents the state of the above widget

class _SplashPageState extends State<SplashPage> {

  /// Opacity used to handle the fade animation

  var _opacity = 0.0;

  @override
  void initState() {
    /// Starts the fade animation after 0.3 seconds from the start
    Future.delayed(
      Duration(milliseconds: 300),
        () {
        setState(() {
          _opacity = 1.0;
        });
      }
    );
    /// Opens the home page after 2.5 seconds from the start
    Future.delayed(
      Duration(seconds: 2),
      () async {
        return Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) {
                  if (FirebaseAuth.instance.currentUser == null) {
                    return WelcomePage();
                  }
                  try {
                    FirebaseMessaging.instance.subscribeToTopic(topicEmail(getEmail(context)));
                  } catch (e) { print(e); }
                  return HomePage();
                },
                transitionDuration: Duration(seconds: 0)
            )
        );
      });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    /// Sets the width and the height to the device, which won't change after the
    /// application gets launched
    width = size.width;
    height = size.height;
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(
            milliseconds: 500
          ),
          child: Image.asset(
            "resources/images/logo.png",
            height: height / 8
          )
        )
      )
    );
  }
}