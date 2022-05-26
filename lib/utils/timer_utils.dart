import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:focus/activities/activities.dart';
import 'package:focus/files/files.dart';
import 'package:focus/main.dart';
import 'package:focus/models/models.dart';
import 'package:focus/pages/forest/forest_page.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/pages/sounds/sounds_page.dart';
import 'package:focus/pages/sounds/sounds_page_widgets.dart';
import 'package:focus/stats/stats.dart';
import 'package:focus/timeline/timeline.dart';
import 'package:focus/utils/coins_utilities.dart';
import 'package:focus/utils/date_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

import 'data_utils.dart';
import 'messages_utils.dart';
import 'notifications_utils.dart';

/// Returns the text contained in the timer

double initialValue(TimerStatusModel model, TimerModel model2, MenuModel model3) {
  double remaining = model2.remainingSeconds.toDouble();
  double minutes = model2.selectedMinutes.toDouble();
  switch (model.status) {
    case TimerStatus.WAITING:
      if (!model3.selectedTimer) return 0;
      return minutes;
    case TimerStatus.STARTED:
    case TimerStatus.BREAK:
      return remaining;
    case TimerStatus.CANCELED:
    case TimerStatus.FINISHED:
      return minutes;
  }
}

/// This method returns the text contained by the timer

String timerText(TimerStatusModel model, int minutes, int seconds, double value) {
  switch (model.status) {
    case TimerStatus.WAITING:
      return value.toInt().toString() + ":00";
    case TimerStatus.STARTED:
    case TimerStatus.BREAK:
      return "$minutes:${seconds < 10 ? "0" + seconds.toString() : seconds}";
    case TimerStatus.FINISHED:
      return ":)";
    case TimerStatus.CANCELED:
      return ":(";
  }
}

/// This method returns the color of the timer slider based on its state

Color barColor(TimerStatus status, BuildContext context, bool track, bool chronometer) {
  final color = Theme.of(context).primaryColor;
  switch (status) {
    case TimerStatus.WAITING:
    case TimerStatus.STARTED:
    case TimerStatus.BREAK:
      if (track) return color.withOpacity(0.4);
      if (chronometer) return Colors.transparent;
      return color;
    case TimerStatus.CANCELED:
      return Color.fromRGBO(226, 94, 94, 1.0);
    case TimerStatus.FINISHED:
      return color;
  }
}

void playSound(MenuModel model3) async {
  await player.setAsset("resources/sounds/${sounds[model3.selectedSound - 1].toLowerCase()}.mp3");
  await player.setLoopMode(LoopMode.one);
  player.play();
}

/// There's the risk that in iOS (and sometimes even Android), the timer doesn't proceed
/// while the app is in the background, so I found another way.

DateTime startedTime = DateTime.now();

/// This method starts the timer

void startTimer(BuildContext context, [double remainingSeconds = -1]) {
  TimerStatusModel model = Provider.of<TimerStatusModel>(context, listen: false);
  TimerModel model2 = Provider.of<TimerModel>(context, listen: false);
  MenuModel model3 = Provider.of<MenuModel>(context, listen: false);
  ActivitiesModel model4 = Provider.of<ActivitiesModel>(context, listen: false);
  if (model.status != TimerStatus.BREAK) model.status = TimerStatus.STARTED;
  if (model.status != TimerStatus.BREAK) {
    model2.totalSeconds = model2.selectedMinutes * 60;
    model2.remainingSeconds = remainingSeconds == -1 ? model2.selectedMinutes * 60 : remainingSeconds;
  } else {
    model2.totalSeconds = (model3.selectedPomodoro && (model3.repetitions - model3.remainingRepetitions) % 4 == 0) ? model3.longBreakDuration * 60 : model3.shortBreakDuration * 60;
    model2.remainingSeconds = (model3.selectedPomodoro && (model3.repetitions - model3.remainingRepetitions) % 4 == 0) ? model3.longBreakDuration * 60 : model3.shortBreakDuration * 60;
  }
  timerController.animateBack(0, duration: Duration(milliseconds: 0))
      .then((value) => timerController.animateBack(1, duration: Duration(milliseconds: 1000)));
  try {
    timeline["timeline"].putIfAbsent(formatDate(DateTime.now()), () => []);
    final z = [
      "You failed",
      "Hai perso",
      "Vous avez échoué",
      "Fallaste",
      "Du hast versagt"
    ];
    timeline["timeline"][formatDate(DateTime.now())].insert(0, {
      "start": "${formatTime(DateTime.now().hour)}:${formatTime(DateTime.now().minute)}",
      "end": "-",
      "plant": plantNames[model3.selectedTree],
      "activity": "",
      "successful": true,
      "text": z[locales.indexOf(locale.value)]
    });
  } catch (e) {}
  /// Start music
  if (model3.selectedSound != 0) playSound(model3);
  /// lol
  try {
    timer?.cancel();
  } catch (e) {}
  Wakelock.enable();
  startedTime = DateTime.now();
  final w = [
    ["You made it!", "Here's", "coins"],
    ["Ce l'hai fatta!", "Ecco a te", "monete"],
    ["Tu as réussi!", "Voici", "pièces"],
    ["¡Lo lograste!", "Aquí está", "monedas"],
    ["Du hast es geschafft!", "Hier ist", "Münzen"]
  ];
  initializeTimeZones();
  FlutterNativeTimezone.getLocalTimezone().then((value) {
    flutterLocalNotificationsPlugin.zonedSchedule(
        11159,
        w[locales.indexOf(locale.value)][0],
        "${w[locales.indexOf(locale.value)][1]} $coins ${w[locales.indexOf(locale.value)][2]}",
        TZDateTime.from(DateTime.now(), getLocation(value)).add(Duration(minutes: model2.selectedMinutes.toInt())),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true
    );
  });
  timer = Timer.periodic(
    Duration(seconds: 1),
        (Timer timer) {
      if (model2.remainingSeconds == 0) {
        void a() async {
          minutePassed(model3, model4, model2.selectedMinutes.toInt());
          timer.cancel();
          playFinishedSound();
          (timeline["timeline"][formatDate(DateTime.now())] as List).first["end"] =
          "${formatTime(DateTime
              .now()
              .hour)}:${formatTime(DateTime
              .now()
              .minute)}";
          (timeline["timeline"][formatDate(DateTime.now())] as List).first["activity"] =
              model3.selectedActivity - 1;
          final z = [
            "You succeeded",
            "Ci sei riuscito!",
            "Vous avez réussi",
            "Tuviste éxito",
            "Du warst erfolgreich"
          ];
          (timeline["timeline"][formatDate(DateTime.now())] as List).first["text"] = z[locales.indexOf(locale.value)];
          TIMELINE_FILE.write(jsonEncode(timeline));
          int coins = calculateAmount((model2.totalSeconds / 60).round());
          model.status = TimerStatus.FINISHED;
          addCoins(coins);
          Wakelock.disable();

          if (model.status != TimerStatus.BREAK) {
            DateTime date = DateTime.now();
            Activity activity = model4.activities["general"][model3.selectedGeneralActivity - 1];
            if (activitiesJson[activity.name][date.year.toString()][date.month.toString()][date.day].toDouble() >= activity.goal / 60) {
              timeline["habits"].putIfAbsent(activity.name, () => []);
              timeline["habits"][activity.name].add(formatDate(date));
              TIMELINE_FILE.write(jsonEncode(timeline));
            }
            if (model3.selectedActivity != 1) {
              final folder = model4.activities["specific"];
              final generalFolder = folder[folder.keys.elementAt(model3.selectedGeneralActivity - 1)];
              final specific = generalFolder[model3.selectedActivity - 1];
              if (activitiesJson[specific.name][date.year.toString()][date.month.toString()][date.day].toDouble() >= specific.goal / 60) {
                timeline["habits"].putIfAbsent(specific.name, () => []);
                timeline["habits"][specific.name].add(formatDate(date));
                TIMELINE_FILE.write(jsonEncode(timeline));
              }
            }
          }
        }
        if (model3.selectedPomodoro) {
          if (model.status == TimerStatus.STARTED) {
            if (model3.remainingRepetitions != 0) {
              model3.remainingRepetitions -= 1;
              model.status = TimerStatus.BREAK;
              playFinishedSound();
              timer.cancel();
              startTimer(context);
            } else {
              a();
            }
          } else {
            model.status = TimerStatus.WAITING;
            playFinishedSound();
            Vibration.hasVibrator().then((value) {
              if (value) Vibration.vibrate();
            });
              timer.cancel();
              startTimer(context);
          }
        } else {
          if (model.status == TimerStatus.BREAK) {
            model.status = TimerStatus.WAITING;
            timer.cancel();
            playFinishedSound();
          } else {
            a();
          }
        }
      } else {
        final difference = DateTime.now().difference(startedTime).inSeconds;
        if (difference > model2.totalSeconds) {
          model2.remainingSeconds = 0;
        } else {
          model2.remainingSeconds = model2.totalSeconds - difference;
        }
      }
    }
  );
}

Future<void> saveTimeSuccessFailuresToDatabase() async {
 try {
   final today = DateTime.now();
   DateTime? date = null;
   if (today.isBefore(DateTime(today.year, 4, 1))) {
     date = DateTime(today.year, 1, 1);
   } else if (date == null && today.isBefore(DateTime(today.year, 8, 1))) {
     date = DateTime(today.year, 4, 1);
   } else if (date == null) {
     date = DateTime(today.year, 8, 1);
   }
   num minutes = 0;
   int success = 0;
   int failures = 0;
   void a () {
     for (DateTime a = today; (a.year != date?.year || a.month != date?.month || a.day != date?.day); a = a.subtract(Duration(days: 1))) {
       final b = timeJson["${a.year}"]["${a.month}"]["${a.day}"];
       if (b != null) minutes += (b.first);
       final time = timeline["timeline"][formatDate(a)];
       if (time != null) {
         (time as List).forEach((element) {
           if (element["successful"] == true) success++;
           else if (element["successful"] == false) failures++;
         });
       }
     }
     lastDataUpdate = DateTime.now().millisecondsSinceEpoch;
     PROFILE_FILE.write(
         jsonEncode({
           "email": FirebaseAuth.instance.currentUser?.email,
           "lastEdit": lastEdit,
           "username": username,
           "coins": coins,
           "realTrees": realTrees,
           "plants": plantsUnlocked,
           "sounds": soundsUnlocked,
           "lang": locale.value.languageCode,
           "lastDataUpdate": lastDataUpdate
         })
     );
   }
   if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastDataUpdate)).inDays > 3) {
     a();
     FirebaseFirestore.instance.collection("users")
         .doc(FirebaseAuth.instance.currentUser?.email)
         .update({
       "minutes": minutes.toInt(),
       "success": success,
       "failures": failures
     });
   }
 } catch (e) {
   print("$e");
 }
}

/// This method starts the chronometer

void startChronometer(BuildContext context) {
  TimerStatusModel model = Provider.of<TimerStatusModel>(context, listen: false);
  TimerModel model2 = Provider.of<TimerModel>(context, listen: false);
  MenuModel model3 = Provider.of<MenuModel>(context, listen: false);
  model.status = TimerStatus.STARTED;
  model2.remainingSeconds = 0;
  timerController.animateBack(0, duration: Duration(milliseconds: 0))
      .then((value) => timerController.animateBack(1, duration: Duration(milliseconds: 1000)));
  timeline["timeline"].putIfAbsent(formatDate(DateTime.now()), () => []);
  final z = [
    "You failed",
    "Hai perso",
    "Vous avez échoué",
    "Fallaste",
    "Du hast versagt"
  ];
  timeline["timeline"][formatDate(DateTime.now())].insert(0, {
    "start": "${formatTime(DateTime.now().hour)}:${formatTime(DateTime.now().minute)}",
    "end": "-",
    "plant": plantNames[model3.selectedTree],
    "activity": "",
    "successful": true,
    "text": z[locales.indexOf(locale.value)]
  });
  if (model3.selectedSound != 0) playSound(model3);
  Wakelock.enable();
  final w = [
    ["You made it!", "Here's", "coins"],
    ["Ce l'hai fatta!", "Ecco a te", "monete"],
    ["Tu as réussi!", "Voici", "pièces"],
    ["¡Lo lograste!", "Aquí está", "monedas"],
    ["Du hast es geschafft!", "Hier ist", "Münzen"]
  ];
  MethodChannel("com.focus.mobile.focus").invokeMethod('getTimeZoneName').then((value) {
    flutterLocalNotificationsPlugin.zonedSchedule(
        11159,
        w[locales.indexOf(locale.value)][0],
        "${w[locales.indexOf(locale.value)][1]} $coins ${w[locales.indexOf(locale.value)][2]}",
        TZDateTime.from(DateTime.now(), getLocation(value)).add(Duration(minutes: model2.selectedMinutes.toInt())),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true
    );
  });
  startedTime = DateTime.now();
  timer = Timer.periodic(
    Duration(seconds: 1),
        (Timer timer) {
      if (model2.remainingSeconds == 7200) {
        timer.cancel();
        minutePassed(model3, Provider.of<ActivitiesModel>(context, listen: false), 120);
        playFinishedSound();
        (timeline["timeline"][formatDate(DateTime.now())] as List).first["end"] = "${formatTime(DateTime.now().hour)}:${formatTime(DateTime.now().minute)}";
        (timeline["timeline"][formatDate(DateTime.now())] as List).first["activity"] = Provider.of<MenuModel>(context, listen: false).selectedActivity - 1;
        final z = [
          "You succeeded",
          "Ci sei riuscito!",
          "Vous avez réussi",
          "Tuviste éxito",
          "Du warst erfolgreich"
        ];
        (timeline["timeline"][formatDate(DateTime.now())] as List).first["text"] = z[locales.indexOf(locale.value)];
        TIMELINE_FILE.write(jsonEncode(timeline));
        int coins = calculateAmount((model2.totalSeconds / 60).round());
        addCoins(coins);
        model.status = TimerStatus.FINISHED;
        Wakelock.disable();
      } else {
        final difference = DateTime.now().difference(startedTime).inSeconds;
        if (difference > 7200) {
          model2.remainingSeconds = 7200;
        } else {
          model2.remainingSeconds = difference.toDouble();
        }
      }
    },
  );
}

String killerName = "";

/// This method stops the timer

void stopTimer(BuildContext context, [bool killer = false]) async {
  TimerStatusModel model = Provider.of<TimerStatusModel>(context, listen: false);
  TimerModel model2 = Provider.of<TimerModel>(context, listen: false);
  MenuModel model3 = Provider.of<MenuModel>(context, listen: false);
  timerController.animateBack(0, duration: Duration(milliseconds: 0))
      .then((value) => timerController.animateBack(1, duration: Duration(milliseconds: 1000)));
  model2.remainingSeconds = model2.totalSeconds;
  timer?.cancel();
  (timeline["timeline"][formatDate(DateTime.now())] as List).first["end"] = "${formatTime(DateTime.now().hour)}:${formatTime(DateTime.now().minute)}";
  (timeline["timeline"][formatDate(DateTime.now())] as List).first["activity"] = model3.selectedActivity - 1;
  player.stop();
  flutterLocalNotificationsPlugin.cancel(11159);
  if (model3.selectedTimer) {
    (timeline["timeline"][formatDate(DateTime.now())] as List).first["successful"] = false;
    model.status = TimerStatus.CANCELED;
    if (killer) sendPushMessage(
        type: "failed",
        topic: key.value,
        body: jsonEncode({
          "failed": true,
          "failer": username.value
        })
    );
    final w = [
      ["Ouch!", "You stopped focusing and killed your tree"],
      ["Ouch!", "Hai smesso di concentrarti e hai ucciso il tuo albero"],
      ["Aïe", "Tu as arrêté de tu concentrer et as tué ton arbre"],
      ["¡Ay!", "Dejaste de concentrarte y mataste tu árbol"],
      ["Autsch", "Du hast aufgehört zu konzentrieren und deinen Baum getötet"]
    ];
    flutterLocalNotificationsPlugin.show(
        11149,
        w[locales.indexOf(locale.value)][0],
        w[locales.indexOf(locale.value)][1],
        platformChannelSpecifics
    );
  } else {
    if (timer!.tick > 600) {
      (timeline["timeline"][formatDate(DateTime.now())] as List).first["successful"] = true;
      model.status = TimerStatus.FINISHED;
    } else {
      (timeline["timeline"][formatDate(DateTime.now())] as List).first["successful"] = false;
      model.status = TimerStatus.CANCELED;
      if (killer) sendPushMessage(
          type: "failed",
          topic: key.value,
          body: jsonEncode({
            "failed": true,
            "failer": username.value
          })
      );
    }
  }
  TIMELINE_FILE.write(jsonEncode(timeline));
  playFinishedSound();
  timer?.cancel();
  Wakelock.disable();
}

void playFinishedSound() async {
  await player.setLoopMode(LoopMode.off);
  await player.setAsset("resources/sounds/notification.mp3");
  player.play();
}