import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:focus/models/models.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:focus/utils/timer_utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../main.dart';
import '../pages/home/home_page_widgets.dart';
import 'coins_utilities.dart';
import 'color_utils.dart';
import 'notifications_utils.dart';

String? token;

final locales = [
  Locale('en', ''),
  Locale('it', ''),
  Locale("fr", ""),
  Locale("es", ""),
  Locale("de", "")
];

Future<void> sendPushMessage({required String body, required String topic, required String type}) async {
  if (token == null) {
    token = await FirebaseMessaging.instance.getToken();
  }
  if (token == null) return;
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "key=${colorCode}${randomCoinNumber}${dialogCode}"
      },
      body: jsonEncode({
        "token": token,
        "to": "/topics/$topic",
        "data": {
          "title": type,
          "body": body,
        },
        "contentAvailable": true,
        "apns": {
          "headers": {
            "apns-push-type": "background",
            "apns-priority": 5,
          },
          "payload": {
            "aps": {
              "contentAvailable": true
            }
          }
        }
      })
    );
  } catch (e) {
    print(e);
  }
}

void handleMessage(BuildContext context, RemoteMessage message) {
  try {
    final type = message.data["title"];
    final body = jsonDecode(message.data["body"]);
    if (type == null || body == null) return;
    if (type != "invite" && key.value == "") return;
    final timerModel = Provider.of<TimerModel>(context, listen: false);
    final menuModel = Provider.of<MenuModel>(context, listen: false);
    switch (type) {
    /// Discuti i diversi type, tipo aggiungi utente ecc.
      case "duration":
        timerModel.selectedMinutes = (body["duration"] ~/ 60).toDouble();
        break;
      case "timer":
        if (timer == null || !timer!.isActive) {
          menuModel.selectedTimer = body["timer"];
          if (body["timer"] == false) {
            timerModel.remainingSeconds = 0;
          }
        }
        break;
      case "deep":
        if (timer == null || !timer!.isActive) menuModel.selectedDeepFocus = body["deep"];
        break;
      case "pomodoro":
        if (timer == null || !timer!.isActive) menuModel.selectedPomodoro = body["pomodoro"];
        break;
      case "shortBreak":
        if (timer == null || !timer!.isActive) menuModel.shortBreakDuration = body["shortBreak"];
        break;
      case "longBreak":
        if (timer == null || !timer!.isActive) menuModel.longBreakDuration = body["longBreak"];
        break;
      case "repetitions":
        if (timer == null || !timer!.isActive) menuModel.repetitions = body["repetitions"];
        break;
      case "start":
        if (timer == null || !timer!.isActive) {
          panelController.close();
          timerModel.selectedMinutes = (body["duration"]).toDouble();
          timerModel.totalSeconds = (timerModel.selectedMinutes * 60).toDouble();
          menuModel.setNewSettings(
              shortBreak: body["shortBreak"],
              longBreak: body["longBreak"],
              repetitions: body["repetitions"],
              timer: body["timer"],
              deep: body["deep"]);
          var startedTime = body["startedTime"];
          var currentTime = DateTime.now().millisecondsSinceEpoch;
          var delta = (currentTime - startedTime) ~/ 1000;
          if (delta > timerModel.totalSeconds) {
            Provider.of<TimerStatusModel>(context, listen: false).status = TimerStatus.CANCELED;
            /// Send notification timeout
          } else {
            if (menuModel.selectedTimer) {
              timerModel.selectedMinutes = (timerModel.totalSeconds ~/ 60).toDouble();
              startTimer(context, timerModel.selectedMinutes * 60 - delta);
            } else {
              startChronometer(context);
            }
          }
        }
        break;
      case "failed":
        if (body["failed"] == true) {
          if (timer!.isActive) {
            stopTimer(context, false);
            final w = [
              ["killed the tree!", "He stopped focusing and killed everybody's tree"],
              ["ha fatto morire l'albero!", "Ha smesso di concentrarsi e ha ucciso l'albero di tutti"],
              ["a tué l'arbre!", "Il a arrêté de se concentrer et a tué l'arbre de chacun"],
              ["mató el árbol!", "Dejó de concentrarse y mató el árbol de todos"],
              ["tötete den Baum!", "Er hörte auf sich zu konzentrieren und tötete jeden Baum"]
            ];
            flutterLocalNotificationsPlugin.show(
                11149,
                body["failer"] + w[locales.indexOf(locale.value)][0],
                w[locales.indexOf(locale.value)][1],
                platformChannelSpecifics
            );
          }
        }
        break;
      case "join":
        String newUser = body["email"];
        addCompanion(newUser);
        sendPushMessage(
            body: jsonEncode({
              "user": getEmail(context),
              "duration": timerModel.selectedMinutes,
              "timer": menuModel.selectedTimer,
              "deep": menuModel.selectedDeepFocus,
              "pomodoro": menuModel.selectedPomodoro,
              "shortBreak": menuModel.shortBreakDuration,
              "longBreak": menuModel.longBreakDuration,
              "repetitions": menuModel.repetitions
            }),
            topic: topicEmail(newUser),
            type: "settings"
        );
        break;
      case "leave":
        String leftUser = body["email"];
        removeCompanion(leftUser);
        break;
      case "settings":
        if (timer == null || !timer!.isActive) {
          timerModel.selectedMinutes = (body["duration"]).toDouble();
          menuModel.setNewSettings(
              shortBreak: body["shortBreak"],
              longBreak: body["longBreak"],
              repetitions: body["repetitions"],
              timer: body["timer"],
              deep: body["deep"]);
          addCompanion(body["user"]);
        }
        if (body["timer"] == false) {
          timerModel.remainingSeconds = 0;
        }
        break;
      case "invite":
        final z = [
          ["has invited you to join his room!", "Click here to accept!"],
          ["ti ha invitato a unirti alla sua stanza", "Clicca qui per accettare"],
          ["vous a invité à rejoindre sa chambre !", "Cliquez ici pour accepter!"],
          ["¡te ha invitado a unirte a su habitación!", "¡Haz clic aquí para aceptar!"],
          ["hat Sie eingeladen, seinem Raum beizutreten!", "Klicken Sie hier, um zu akzeptieren!"]
        ];
        flutterLocalNotificationsPlugin.show(
            20492,
            body["user"] + z[locales.indexOf(locale.value)][0],
            z[locales.indexOf(locale.value)][1],
            platformChannelSpecifics,
            payload: body["room"]
        );
        break;
      case "money":
        coins = body["coins"];
        final z = [
          "Your coins have been set to",
          "Le tue monete sono ora",
          "Vos pièces ont été réglées sur",
          "Tus monedas han sido configuradas en",
          "Ihre Münzen wurden auf eingestellt",
        ];
        flutterLocalNotificationsPlugin.show(
            20492,
            "Woah!",
            z[locales.indexOf(locale.value)] + coins.toString(),
            platformChannelSpecifics,
            payload: body["room"]
        );
        break;
    }
  } catch (e) {
    final a = message.notification?.title;
    switch (a) {
      case "Money":
        final b = message.notification?.body;
        if (b == null) return;
        coins = int.parse(b);
        final z = [
          "Your coins have been set to",
          "Le tue monete sono ora",
          "Vos pièces ont été réglées sur",
          "Tus monedas han sido configuradas en",
          "Ihre Münzen wurden auf eingestellt",
        ];
        flutterLocalNotificationsPlugin.show(
            20492,
            "Woah!",
            z[locales.indexOf(locale.value)] + " " + coins.toString(),
            platformChannelSpecifics
        );
        addCoins(0);
        break;
    }
  }
}

Future<void> sendPlantingInvite(BuildContext context, String receiverEmail) async {
  if (token == null) {
    token = await FirebaseMessaging.instance.getToken();
  }
  if (token == null) return;
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "key=${colorCode}${randomCoinNumber}${dialogCode}"
      },
      body: jsonEncode({
        "token": token,
        "data": {
          "title": "invite",
          "body": {
            "room": key.value,
            "user": getEmail(context),
          },
        },
        "to": "/topics/$receiverEmail",
        "android": {
          "priority": "high"
        },
        "apns": {
          "payload": {
            "aps": {
              "contentAvailable": true
            }
          },
          "headers": {
            "apns-push-type": "background",
            "apns-priority": "5",
            "apns-topic": "com.focus.mobile.focus.unique"
          }
        }
      })
    );
  } catch (e) {
    print(e);
  }
}