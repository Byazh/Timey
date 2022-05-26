import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus/utils/data_utils.dart';

import '../main.dart';

NotificationDetails platformChannelSpecifics = NotificationDetails(
  android: androidPlatformChannelSpecifics,
  iOS: iOSPlatformChannelSpecifics
);

const AndroidNotificationDetails androidPlatformChannelSpecifics =
AndroidNotificationDetails(
    "12345",
    "focus_app",
    channelDescription: "App to focus",
    playSound: false,
    importance: Importance.high,
    priority: Priority.high
);

const IOSNotificationDetails iOSPlatformChannelSpecifics =
IOSNotificationDetails(
  presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
  presentBadge: false,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
  presentSound: false
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: true
    );
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}

void showSnackBar(BuildContext context, String text, [Color color = const Color.fromRGBO(80, 163, 135, 1), Color textColor = Colors.white70]) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            text,
          style: TextStyle(
            color: textColor
          ),
        ),
        backgroundColor: color,
        margin: EdgeInsets.only(
            bottom: height - height / 7,
            left: width / 20,
            right: width / 20
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 30)
        ),
        action: SnackBarAction(
          label: "Ok",
          textColor: textColor,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      )
  );
}