import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:focus/activities/activities.dart';
import 'package:focus/files/files.dart';
import 'package:focus/models/models.dart';
import 'package:focus/pages/statistics/statistics_page_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Map<String, dynamic> timeJson = {
  /*"2021": {
    "minutes": 203,
    "1": {
      "minutes": 49,
      "1": [
        1000, // total
        200
      ]
    }
  }*/
};

List<Statistic>? dailyData(DateTime day) {
  List<Statistic> data = [];
  try {
    for (int i = 0; i < 24; i++) {
      data.add(
          Statistic(
              i.toString(),
              timeJson["${day.year}"]["${day.month}"]["${day.day}"].elementAt(i + 1).toDouble()
          )
      );
    }
  } on Error {
    return null;
  }
  return data;
}

List<Statistic>? weeklyData(DateTime day) {
  List<Statistic> data = [];
  DateTime monday = day.subtract(Duration(days: day.weekday - 1));
  try {
    for (int i = 0; i < 7; i++) {
      DateTime current = monday.add(Duration(days: i));
      data.add(
          Statistic(
              current.day.toString(),
              timeJson["${current.year}"]["${current.month}"]["${current.day}"].elementAt(0).toDouble()
          )
      );
    }
  } on Error {
    return null;
  }
  return data;
}

List<Statistic>? monthlyData(DateTime day) {
  List<Statistic> data = [];
  int days = DateTimeRange(
      start: DateTime(day.year, day.month),
      end: DateTime(day.year, day.month + 1))
      .duration
      .inDays;
  try {
    for (int i = 1; i <= days; i++) {
      DateTime current = DateTime(day.year, day.month, i);
      data.add(
          Statistic(
              current.day.toString(),
              timeJson["${current.year}"]["${current.month}"]["${current.day}"].elementAt(0).toDouble()
          )
      );
    }
  } on Error {
    return null;
  }
  return data;
}

List<Statistic>? yearlyData(DateTime day) {
  List<Statistic> data = [];
  try {
    for (int i = 1; i < 13; i++) {
      DateTime current = DateTime(day.year, i);
      data.add(
          Statistic(
              i.toString(),
              timeJson["${current.year}"]["$i"]["minutes"].toDouble()
          )
      );
    }
  } on Error {
    return null;
  }
  return data;
}

String totalFocusText(String period, DateTime selected, BuildContext context) {
  String string = AppLocalizations.of(context)!.totalFocusTime;
  Duration time = Duration(seconds: 0);
  try {
    switch (period) {
      case "Day":
        time = Duration(minutes: timeJson["${selected.year}"]["${selected.month}"]["${selected.day}"][0]);
        break;
      case "Week":
        DateTime monday = selected.subtract(Duration(days: selected.weekday - 1));
        int total = 0;
        for (int i = 0; i < 7; i++) {
          DateTime current = monday.add(Duration(days: i));
          total += timeJson["${current.year}"]["${current.month}"]["${current.day}"][0] as int;
        }
        time = Duration(minutes: total);
        break;
      case "Month":
        time = Duration(minutes: timeJson["${selected.year}"]["${selected.month}"]["minutes"]);
        break;
      case "Year":
        time = Duration(minutes: timeJson["${selected.year}"]["${selected.month}"]["minutes"]);
        break;
    }
  } on Error {}
  string += time.inHours.toString() + "h " + (time.inMinutes - time.inHours * 60).toString() + "m";
  return string;
}

String totalPeriodText(String period, DateTime selected, BuildContext context) {
  String string = "${AppLocalizations.of(context)!.ofThePeriod} ";
  switch (period) {
    case "Day":
      string += AppLocalizations.of(context)!.day;
      break;
    case "Week":
      string += AppLocalizations.of(context)!.day;
      break;
    case "Month":
      string += AppLocalizations.of(context)!.week;
      break;
    case "Year":
      string += AppLocalizations.of(context)!.year;
      break;
  }
  return string.toLowerCase();
}

List<Statistic>? weeklyPeriodData(DateTime dateTime) {
  List<Statistic> data = [];
  List<int> hours = List.generate(24, (index) => 0, growable: true);
  DateTime monday = dateTime.subtract(Duration(days: dateTime.weekday - 1));
  try {
    for (int day = 0; day < 7; day++) {
      DateTime current = monday.add(Duration(days: day));
      for (int hour = 1; hour < 24; hour++) {
        hours[hour] += timeJson["${current.year}"]["${current.month}"]["${current.day}"].elementAt(hour) as int;
      }
    }
    for(int i = 0; i < 24; i++) {
      data.add(
          Statistic(
              i.toString(),
              hours.elementAt(i).toDouble()
          )
      );
    }
  } on Error {
    return null;
  }
  return data;
}

List<Statistic>? monthlyPeriodData(DateTime dateTime) {
  List<Statistic> data = [];
  List<int> days = List.generate(7, (index) => 0, growable: true);
  int numberOfDays = DateTimeRange(
      start: DateTime(dateTime.year, dateTime.month),
      end: DateTime(dateTime.year, dateTime.month + 1))
      .duration
      .inDays;
  try {
    for (int day = numberOfDays; day > 0; day--) {
      DateTime current = DateTime(dateTime.year, dateTime.month, day);
      days[current.weekday - 1] += days.elementAt(current.weekday - 1) + timeJson["${current.year}"]["${current.month}"]["${current.day}"][0] as int;
    }
    for(int i = 0; i < 7; i++) {
      data.add(
          Statistic(
              (i).toString(),
              days.elementAt(i).toDouble()
          )
      );
    }
  } on Error {
    return null;
  }
  return data;
}

List<Statistic>? yearlyPeriodData(DateTime dateTime) {
  List<Statistic> data = [];
  List<int> months = List.generate(12, (index) => 0, growable: true);
  try {
    for (int month = 1; month < 13; month++) {
      DateTime current = DateTime(dateTime.year, month);
      months[month - 1] += timeJson["${current.year}"]["${current.month}"]["minutes"] as int;
    }
    for(int i = 0; i < 12; i++) {
      data.add(
          Statistic(
              (i + 1).toString(),
              months.elementAt(i).toDouble()
          )
      );
    }
  } on Error {
    return null;
  }
  return data;
}

/// Create calendar if needed

void createCalendar() {
  final today = DateTime.now();
  /// Ensure there is no null
  timeJson.putIfAbsent(today.year.toString(), () => calendarBase());
  activitiesJson.keys.forEach((element) {
    activitiesJson[element].putIfAbsent(today.year.toString(), () => calendarActivitiesBase());
  });
}

/// If total minutes in that day, week, month or year are 0, then i show the unavailable message3

Map<String, dynamic> calendarBase() {
  var json = <String, dynamic>{
    "minutes": 0,
    "reasons": [0, 0, 0, 0, 0, 0]
  };
  for(int month = 1; month < 13; month++) {
    var currentMonth = <String, dynamic>{
      "minutes": 0,
      "reasons": [0, 0, 0, 0, 0, 0]
    };
    for (int day = 1; day < 32; day++) {
      var currentDay = <int>[];
      for(int hour = 0; hour < 31; hour++) {
        currentDay.add(0);
      }
      currentMonth.putIfAbsent(day.toString(), () => currentDay);
    }
    json.putIfAbsent(month.toString(), () => currentMonth);
  }
  return json;
}

Map<String, dynamic> calendarActivitiesBase() {
  var json = <String, dynamic>{
    "minutes": 0
  };
  for(int month = 1; month < 13; month++) {
    var currentMonth = <int>[];
    for (int day = 1; day < 32; day++) {
      currentMonth.add(0);
    }
    json.putIfAbsent(month.toString(), () => currentMonth);
  }
  return json;
}

void addActivityToCalendar(Activity activity, {bool specific = false, String general = "Null", Map<String, dynamic> value = const {}}) {
  activitiesJson.putIfAbsent(activity.name, () => value.length == 0 ? {
    "minutes": 0,
    "specific": specific,
    "general": general,
    "${DateTime.now().year}": calendarActivitiesBase()
  } : value);
}

void removeActivityFromCalendar(String activity) {
  activitiesJson.removeWhere((key, value) => key == activity);
}

void editActivityFromCalendar(String activity, String oldActivity) {
  if (activitiesJson.containsKey(activity)) return;
  removeActivityFromCalendar(oldActivity);
}

List<Statistic>? dailyActivities(DateTime dateTime, String selectedGeneral, ActivitiesModel model) {
  List<Statistic> data = [];
  try {
    activitiesJson.forEach((key, value) {
      if (selectedGeneral == "Overall") {

        data.add(Statistic(key, getActivitiesPercentage("Day", dateTime, key)));
      } else {
        if (value["specific"] == false) return;
        if (value["general"] == selectedGeneral) {
          data.add(Statistic(key, getSpecificActivitiesPercentage("Day", dateTime, key, value["general"])));
        }
      }
    });
  } on Error {
    return null;
  }
  return data;
}

List<Statistic>? weeklyActivities(DateTime dateTime, String selectedGeneral, ActivitiesModel model) {
  List<Statistic> data = [];
  try {
    activitiesJson.forEach((key, value) {
      if (selectedGeneral == "Overall") {
        data.add(Statistic(key, getActivitiesPercentage("Week", dateTime, key)));
      } else {
        if (value["specific"] == false) {
          if (value["general"] == selectedGeneral) {
            data.add(Statistic(key, getSpecificActivitiesPercentage("Week", dateTime, key, value["general"])));
          }
        }
      }
    });
  } on Error {
    return null;
  }
  return data;
}

List<Statistic>? monthlyActivities(DateTime dateTime, String selectedGeneral, ActivitiesModel model) {
  List<Statistic> data = [];
  try {
    activitiesJson.forEach((key, value) {
      if (selectedGeneral == "Overall") {
        data.add(Statistic(key, getActivitiesPercentage("Month", dateTime, key)));
      } else {
        if (value["specific"] == false) return;
        if (value["general"] == selectedGeneral) {
          data.add(Statistic(key, getSpecificActivitiesPercentage("Month", dateTime, key, value["general"])));
        }
      }
    });
  } on Error {
    return null;
  }
  return data;
}

List<Statistic>? yearlyActivities(DateTime dateTime, String selectedGeneral, ActivitiesModel model) {
  List<Statistic> data = [];
  try {
    activitiesJson.forEach((key, value) {
      if (selectedGeneral == "Overall") {
        data.add(Statistic(key, getActivitiesPercentage("Year", dateTime, key)));
      } else {
        if (value["specific"] == false) return;
        if (value["general"] == selectedGeneral) {
          data.add(Statistic(key, getSpecificActivitiesPercentage("Year", dateTime, key, value["general"])));
        }
      }
    });
  } on Error {
    return null;
  }
  return data;
}

void minutePassed(MenuModel model, ActivitiesModel model2, int minutes) {
  var today = DateTime.now();
  var year = timeJson["${today.year}"]["${today.month}"];
  timeJson["${today.year}"]["minutes"] += minutes;
  year["minutes"] += minutes;
  year["${today.day}"][0] += minutes;
  year["${today.day}"][today.hour] += minutes;
  var generalActivity = model2.activities["general"].elementAt(model.selectedGeneralActivity - 1).name;
  if (model.selectedActivity != 1) {
    final folder = model2.activities["specific"];
    final generalFolder = folder[folder.keys.elementAt(model.selectedGeneralActivity - 1)];
    final activity = activitiesJson[generalFolder.elementAt(model.selectedActivity - 1).name];
    activity["minutes"] += minutes;
    activity["${today.year}"]["minutes"] += minutes;
    activity["${today.year}"]["${today.month}"][0] += minutes;
    activity["${today.year}"]["${today.month}"][0] += minutes;
    activity["${today.year}"]["${today.month}"][today.day] += minutes;
  }
  var general = activitiesJson[generalActivity];
  general["minutes"] += minutes;
  general["${today.year}"]["minutes"] += minutes;
  general["${today.year}"]["${today.month}"][0] += minutes;
  general["${today.year}"]["${today.month}"][today.day] += minutes;
  STATS_FILE.write(jsonEncode({
    "time": timeJson,
    "activities": activitiesJson
  }));
}

Map<String, dynamic> activitiesJson = {
  /*"Study": {
  "specific": false,
    "minutes": 39403,
    "2021": {
      "minutes": 2923,
      "1": [
        0, /// total
        0
      ]
    }
  },*/
};

double? getActivitiesPercentage(String period, DateTime dateTime, String activity) {
  var totalTime = 0.0;
  try {
    switch(period) {
      case "Day":
        totalTime = activitiesJson[activity]["${dateTime.year}"]["${dateTime.month}"][dateTime.day].toDouble();
        break;
      case "Week":
        DateTime monday = dateTime.subtract(Duration(days: dateTime.weekday - 1));
        for (int i = 0; i < 7; i++) {
          DateTime current = monday.add(Duration(days: i));
          totalTime += activitiesJson[activity]["${current.year}"]["${current.month}"][current.day];
        }
        break;
      case "Month":
        totalTime = activitiesJson[activity]["${dateTime.year}"]["${dateTime.month}"][0].toDouble();
        break;
      case "Year":
        totalTime = activitiesJson[activity]["${dateTime.year}"]["minutes"].toDouble();
        break;
    }
  } catch (e) {
    print(e);
  }
  return totalTime;
}

double? getSpecificActivitiesPercentage(String period, DateTime dateTime, String activity, String general) {
  var totalTime = 0.0;
  switch(period) {
    case "Day":
      totalTime = activitiesJson[activity]["${dateTime.year}"]["${dateTime.month}"][dateTime.day].toDouble();
      break;
    case "Week":
      DateTime monday = dateTime.subtract(Duration(days: dateTime.weekday - 1));
      for (int i = 0; i < 7; i++) {
        DateTime current = monday.add(Duration(days: i));
        totalTime += activitiesJson[activity]["${current.year}"]["${current.month}"][current.day].toDouble();
      }
      break;
    case "Month":
      totalTime = activitiesJson[activity]["${dateTime.year}"]["${dateTime.month}"][0].toDouble();
      break;
    case "Year":
      totalTime = activitiesJson[activity]["${dateTime.year}"]["minutes"].toDouble();
      break;
  }
  return totalTime;
}