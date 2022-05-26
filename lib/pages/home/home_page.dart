import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:focus/models/models.dart';
import 'package:focus/utils/data_utils.dart';
import 'package:focus/utils/messages_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:focus/utils/timer_utils.dart';
import 'package:focus/utils/updater_utils.dart';
import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';
import 'home_page_widgets.dart';

/// This class represents the home page of the application, which is opened
/// automatically after the splash page

class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

/// This class represents the state of the above widget

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  /// Opacity used to handle the fade animation

  var _opacity = 0.0;

  @override
  void initState() {
    /// Starts the animation
    Future.delayed(
      Duration(milliseconds: 50),
        () => setState(() {
          _opacity = 1.0;
        })
    );
    /// Manage app life cycle
    WidgetsBinding.instance?.addObserver(this);
    FirebaseAuth.instance.currentUser?.reload().then((value) {
      if (FirebaseAuth.instance.currentUser == null) {
        flutterLocalNotificationsPlugin.show(
            1111,
            AppLocalizations.of(context)!.errorWithAccount,
            AppLocalizations.of(context)!.errorWithAccountSub,
            platformChannelSpecifics
        );
        Future.delayed(Duration(milliseconds: 100), () => Navigator.pushReplacementNamed(context, "/auth"));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (forceUpdate == true && openedUpdater == false) {
      showUpdateDialog(context);
      openedUpdater = true;
    }
    initializeNotification(context);
    /// Material widget is needed to have yellow background during the animation's start
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: Duration(milliseconds: 750),
        /// The panel that can be opened and put over the whole page
        child: CustomSlidingUpPanel(
          /// The page
          body: Scaffold(
            resizeToAvoidBottomInset: false,
              /// The app bar
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(height / 13),
                child: CustomAppBar()
              ),
              /// The drawer
              drawer: CustomDrawer(),
              endDrawer: CustomEndDrawer(),
              endDrawerEnableOpenDragGesture: false,
              /// The body of the page
              body: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /// The circled timer
                  TimerWidget(),
                  /// The widget at the bottom, made of the plant, the hill and
                  /// the buttons
                  PlantHillButtonWidget()
                ]
              )
          )
        )
      )
    );
  }

  CancelableOperation? cancelWithTimer;

  /// Manage the app life cycle and control the deep focus feature

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        cancelWithTimer?.cancel();
        break;
      case AppLifecycleState.inactive:
        if (timer == null || !timer!.isActive) return;
        /// If timer has started, then stop it if deep focus is on and the user exits
        final deepFocus = Provider.of<MenuModel>(context, listen: false).selectedDeepFocus;
        if (!deepFocus) return;
        void cancelSession () {
          if (deepFocus) {
            stopTimer(context, true);
            if (key.value != "") {
              sendPushMessage(
                  topic: key.value,
                  type: "failed",
                  body: jsonEncode({
                    "failed": true,
                    "failer": getEmail(context)
                  }
                  )
              );
            }
          }
        }
        /// If the screen is locked, don't kill the tree
        isLockScreen().then((value) {
          if (value == null || value == false) {
            flutterLocalNotificationsPlugin.show(
                24524,
                AppLocalizations.of(context)!.comeBackDeepFocus,
                AppLocalizations.of(context)!.comeBackDeepFocusSub,
                platformChannelSpecifics
            );
            cancelWithTimer = CancelableOperation.fromFuture(
                Future.delayed(Duration(seconds: 10), () {
                  if (timer != null && timer!.isActive && cancelWithTimer != null && !cancelWithTimer!.isCanceled) cancelSession();
                })
            );
          }
        });
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        /// If timer hasn't started, then don't worry
        if (timer == null || !timer!.isActive) return;
        /// If timer has started, then stop it if deep focus is on and the user exits
        final deepFocus = Provider.of<MenuModel>(context, listen: false).selectedDeepFocus;
        if (!deepFocus) return;
        void cancelSession () {
          if (deepFocus) {
            stopTimer(context, true);
            if (key.value != "") {
              sendPushMessage(
                topic: key.value,
                type: "failed",
                body: jsonEncode({
                  "failed": true,
                  "failer": getEmail(context)
                  }
                )
              );
            }
          }
        }
        isLockScreen().then((value) {
          if (value == null || value == false) {
            flutterLocalNotificationsPlugin.show(
                24524,
                AppLocalizations.of(context)!.comeBackDeepFocus,
                AppLocalizations.of(context)!.comeBackDeepFocusSub,
                platformChannelSpecifics
            );
            cancelWithTimer = CancelableOperation.fromFuture(
                Future.delayed(Duration(seconds: 10), () {
                  if (timer != null && timer!.isActive && cancelWithTimer != null && !cancelWithTimer!.isCanceled) cancelSession();
                })
            );
          }
        });
        break;
    }
    super.didChangeAppLifecycleState(state);
  }
}