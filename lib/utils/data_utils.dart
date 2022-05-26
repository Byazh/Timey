import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus/pages/forest/forest_page.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/pages/sounds/sounds_page.dart';
import 'package:focus/pages/sounds/sounds_page_widgets.dart';
import 'package:focus/utils/date_utils.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:focus/utils/timer_utils.dart';
import 'package:focus/utils/updater_utils.dart';
import 'package:focus/utils/welcome_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:focus/files/files.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:focus/utils/coins_utilities.dart';
import 'package:focus/activities/activities.dart';
import 'package:focus/timeline/timeline.dart';
import 'package:focus/stats/stats.dart';
import 'package:focus/models/models.dart';

import '../main.dart';
import '../pages/home/home_page_widgets.dart';
import 'messages_utils.dart';

int lastDataUpdate = DateTime.now().millisecondsSinceEpoch;

bool loaded = false;

bool loaded2 = false;

Future<void> _loadData(BuildContext context) async {
  if (loaded) {
    return;
  }
  loaded = true;
  /// Load activities
  ActivitiesModel model = Provider.of<ActivitiesModel>(context, listen: false);
  final content = await ACTIVITIES_FILE.read();
  if (content.contains("{") && content.contains("}")) {
    Map<String, dynamic> decoded = jsonDecode(content);
    (decoded["general"] as List).forEach((element) {
      var activity = Activity.fromJson(element);
      (model.activities["general"] as List).removeWhere((element) => element.name == activity.name);
      (model.activities["general"] as List).add(Activity.fromJson(element));
    });
    (decoded["specific"] as Map).forEach((key, value) {
      (model.activities["specific"] as Map).putIfAbsent(key, () => List.generate(value.length, (index) => Activity.fromJson(value[index])));
    });
  } else {
    ACTIVITIES_FILE.write(jsonEncode(testActivities()));
    model.activities = testActivities();
  }
  /// Timeline
  final content3 = await TIMELINE_FILE.read();
  if (content3.contains("{") && content3.contains("}")) {
    Map<String, dynamic> decoded = jsonDecode(content3);
    timeline = decoded;
  } else {
    timeline = {
      "timeline": {},
      "habits": {}
    };
  }
  /// Load stats
  final content2 = await STATS_FILE.read();
  if (content2.contains("{") && content2.contains("}")) {
    Map<String, dynamic> decoded = jsonDecode(content2);
    timeJson = decoded["time"];
    activitiesJson = decoded["activities"];
  } else {
    createCalendar();
    registerTestActivities();
    TIMELINE_FILE.write(jsonEncode(timeline));
    STATS_FILE.write(jsonEncode({
      "time": timeJson,
      "activities": activitiesJson
    }));
  }
  final content6 = await PROFILE_FILE.read();
  if (content6.contains("{") && content6.contains("}")) {
    Map<String, dynamic> decoded = jsonDecode(content6);
    try {
      coins = decoded["coins"];
      username.value = decoded["username"];
      realTrees = decoded["realTrees"];
      plantsUnlocked = List<String>.from(decoded["plants"]);
      soundsUnlocked = List<String>.from(decoded["sounds"]);
      lastEdit = decoded["lastEdit"];
      locale.value = Locale(decoded["lang"]);
      lastDataUpdate = decoded["lastDataUpdate"];
    } catch (e) {
      PROFILE_FILE.write(jsonEncode({
        "email": FirebaseAuth.instance.currentUser?.email,
        "lastEdit": 0,
        "coins": 0,
        "username": "Guest",
        "realTrees": 0,
        "plants": ["basic"],
        "sounds": ["rain"],
        "lang": "en",
        "lastDataUpdate": DateTime.now().millisecondsSinceEpoch
      }));
    }
  } else {
    PROFILE_FILE.write(jsonEncode({
      "email": FirebaseAuth.instance.currentUser?.email,
      "lastEdit": 0,
      "coins": 0,
      "username": "Guest",
      "realTrees": 0,
      "plants": ["basic"],
      "sounds": ["rain"],
      "lang": "en",
      "lastDataUpdate": DateTime.now().millisecondsSinceEpoch
    }));
  }
  final content7 = await UPDATE_FILE.read();
  try {
    final decoded = jsonDecode(content7);
    if (decoded["latestVersion"] > version) {
      forceUpdate = decoded["forceUpdate"];
    } else {
      forceUpdate = false;
    }
  } catch (e) {
    UPDATE_FILE.write(jsonEncode({
      "latestVersion": version,
      "forceUpdate": false
    }));
  }
}

void loadData(BuildContext context) async {
  if (loaded2) {
    return;
  }
  loaded2 = true;
  await _loadData(context);
  saveTimeSuccessFailuresToDatabase();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
  );
  /// Initialize the local notifications service
  await NotificationService().init();
  /// Disable all preexisting sounds to avoid looping mixtures
  await player.stop();
  /// Unsubscribe from all topics
  unsubscribe(context).timeout(Duration(milliseconds: 2900));
  checkUpdate();
  loadUserNews(context);
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: false,
      sound: false
  );
  //if (Platform.isIOS) await FirebaseMessaging.instance.getToken();
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    handleMessage(context, event);
  });
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  String? type = message.notification?.title?.toLowerCase();
  final a = message.notification?.body;
  if (type == null || a == null || type != "invite") {
    return;
  }
  switch (type) {
    case "money":
      coins = int.parse(a);
      addCoins(0);
      break;
    case "invite":
      final body = jsonDecode(a);
      flutterLocalNotificationsPlugin.show(
          48492,
          body["title"],
          body["body"],
          platformChannelSpecifics,
          payload: body["room"]
      );
      break;
  }
}

void handleClick(BuildContext context, String room) {
  Navigator.pushNamed(context, "/home");
  String? email = getEmail(context);
  final provider = Provider.of<SingleMultipleModel>(context, listen: false);
  provider.single = false;
  key.value = room;
  provider.createOrJoin = "Join";
  FirebaseMessaging.instance.subscribeToTopic(room);
  addCompanion(email!);
  sendPushMessage(
      body: jsonEncode({
        "email": email
      }),
      type: 'join',
      topic: key.value
  );
}

void initializeNotification(BuildContext context) {
  flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings('mipmap/ic_launcher'),
          iOS: IOSInitializationSettings()
      ),
      onSelectNotification: (payload) async {
        if (payload?.length == 6) {
          Navigator.pushNamed(context, "/home");
          String? email = getEmail(context);
            final provider = Provider.of<SingleMultipleModel>(context, listen: false);
            provider.single = false;
            key.value = payload!;
            provider.createOrJoin = "Join";
            FirebaseMessaging.instance.subscribeToTopic(payload);
            addCompanion(email!);
            sendPushMessage(
                body: jsonEncode({
                  "email": email
                }),
                type: 'join',
                topic: key.value
            );
        }
      }
  );

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    if (message.notification?.title == "invite") handleClick(context, message.data["body"]["room"]);
  });
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message?.notification?.title == "invite") handleClick(context, message?.data["body"]["room"]);
  });
}

Future<String> getImageFilePathFromAssets(String asset) async {
  final byteData = await rootBundle.load(asset);

  final file = File('${(await getTemporaryDirectory()).path}/${asset.split('/').last}');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file.path;
}