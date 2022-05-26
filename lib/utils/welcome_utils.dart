import 'package:flutter/material.dart';
import 'package:focus/activities/activities.dart';
import 'package:focus/stats/stats.dart';
import 'package:focus/timeline/timeline.dart';
import 'package:focus/utils/color_utils.dart';

Map<String, dynamic> testActivities() {
  return <String, dynamic>{
    "general": <Activity>[
      Activity("Study", Colors.red[400]!.toHex(), false, "MTW", 3600),
      Activity("Work", Colors.blue[400]!.toHex(), false, "MTW", 3600),
      Activity("Social", Colors.purple[400]!.toHex(), false, "MTW", 3600),
      Activity("Sport", Colors.orange[400]!.toHex(), false, "MTW", 3600),
      Activity("Entertainment", Colors.green[400]!.toHex(), false, "", 0),
      Activity("Other", Colors.brown[400]!.toHex(), false, "", 0),
    ],
    "specific": <String, List<Activity>>{
      "Study": [Activity("General", Colors.red[400]!.toHex(), false, "", 0),],
      "Work": [Activity("General", Colors.red[400]!.toHex(), false, "", 0),],
      "Social": [Activity("General", Colors.red[400]!.toHex(), false, "", 0),],
      "Sport": [Activity("General", Colors.red[400]!.toHex(), false, "", 0),],
      "Entertainment": [Activity("General", Colors.red[400]!.toHex(), false, "", 0),],
      "Other": [Activity("General", Colors.red[400]!.toHex(), false, "", 0)]
    }
  };
}

void registerTestActivities() {
  addActivityToCalendar(Activity("Study", Colors.red[400]!.toHex(), false, "MTW", 3600));
  addActivityToCalendar(Activity("Work", Colors.red[400]!.toHex(), false, "MTW", 3600));
  addActivityToCalendar(Activity("Social", Colors.red[400]!.toHex(), false, "MTW", 3600));
  addActivityToCalendar(Activity("Sport", Colors.blue[400]!.toHex(), false, "MTW", 3600));
  addActivityToCalendar(Activity("Entertainment", Colors.blue[400]!.toHex(), false, "MTW", 3600));
  addActivityToCalendar(Activity("Other", Colors.blue[400]!.toHex(), false, "MTW", 3600));
}
