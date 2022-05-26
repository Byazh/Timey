import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:focus/pages/home/home_page_widgets.dart';

import 'package:focus/stats/stats.dart';
import 'package:focus/activities/activities.dart';
import 'package:focus/files/files.dart';
import 'package:focus/timeline/timeline.dart';
import 'package:focus/utils/color_utils.dart';

import '../utils/date_utils.dart';

/// This model handles the single and the multi player focus modes

class SingleMultipleModel with ChangeNotifier {

  var _single = true;

  bool get single => _single;

  set single(bool single) {
    if (single != _single) {
      this._single = single;
      this._createOrJoin = "";
      notifyListeners();
    }
  }

  var _createOrJoin = "";

  String get createOrJoin => _createOrJoin;

  set createOrJoin(String createOrJoin) {
    if (createOrJoin != _createOrJoin) {
      this._createOrJoin = createOrJoin;
      notifyListeners();
    }
  }
}

/// This model handles the status of the timer

class TimerStatusModel extends ChangeNotifier {

  var _status = TimerStatus.WAITING;

  TimerStatus get status => _status;

  set status(TimerStatus status) {
    if (status != _status) {
      this._status = status;
      notifyListeners();
    }
  }
}

enum TimerStatus {
  WAITING,
  STARTED,
  BREAK,
  CANCELED,
  FINISHED
}

/// This method handles the characteristics of the timer

class TimerModel with ChangeNotifier {

  var _totalSeconds = 1500.0;

  double get totalSeconds => _totalSeconds;

  set totalSeconds(double totalSeconds) {
    if (totalSeconds != _totalSeconds) {
      this._totalSeconds = totalSeconds;
      notifyListeners();
    }
  }

  var _remainingSeconds = 1500.0;

  double get remainingSeconds => _remainingSeconds;

  set remainingSeconds(double remainingSeconds) {
    this._remainingSeconds = remainingSeconds;
    notifyListeners();
  }

  var _selectedMinutes = 25.0;

  double get selectedMinutes => _selectedMinutes;

  set selectedMinutes(double selectedMinutes) {
    if (selectedMinutes != _selectedMinutes) {
      this._selectedMinutes = selectedMinutes;
      notifyListeners();
    }
  }
}

/// This model handles the characteristics of the focus session

class MenuModel with ChangeNotifier {

  var _selectedTree = 0;

  int get selectedTree => _selectedTree;

  set selectedTree(int selectedTree) {
    if (selectedTree != _selectedTree) {
      this._selectedTree = selectedTree;
      notifyListeners();
    }
  }

  var _selectedSound = 0;

  int get selectedSound => _selectedSound;

  set selectedSound(int selectedSound) {
    if (selectedSound != _selectedSound) {
      this._selectedSound = selectedSound;
      notifyListeners();
    }
  }

  var _selectedGeneralActivity = 1;

  int get selectedGeneralActivity => _selectedGeneralActivity;

  set selectedGeneralActivity(int selectedGeneralActivity) {
    if (selectedGeneralActivity != _selectedGeneralActivity) {
      this._selectedGeneralActivity = selectedGeneralActivity;
      notifyListeners();
    }
  }

  var _selectedActivity = 1;

  int get selectedActivity => _selectedActivity;

  set selectedActivity(int selectedActivity) {
    if (selectedActivity != _selectedActivity) {
      this._selectedActivity = selectedActivity;
      notifyListeners();
    }
  }

  var _selectedTimer = true;

  bool get selectedTimer => _selectedTimer;

  set selectedTimer(bool selectedTimer) {
    if (selectedTimer != _selectedTimer) {
      this._selectedTimer = selectedTimer;
      if (_selectedTimer == false && _selectedPomodoro == true) {
        selectedPomodoro = false;
      }
      notifyListeners();
    }
  }

  var _selectedDeepFocus = false;

  bool get selectedDeepFocus => _selectedDeepFocus;

  set selectedDeepFocus(bool selectedDeepFocus) {
    if (selectedDeepFocus != _selectedDeepFocus) {
      this._selectedDeepFocus = selectedDeepFocus;
      notifyListeners();
    }
  }

  var _selectedPomodoro = false;

  bool get selectedPomodoro => _selectedPomodoro;

  set selectedPomodoro(bool selectedPomodoro) {
    if (selectedPomodoro != _selectedPomodoro) {
      this._selectedPomodoro = selectedPomodoro;
      if (panelController.isPanelShown) panelController.animatePanelToPosition(selectedPomodoro == true ? 1 : 0.6, duration: Duration(milliseconds: 1000), curve: Curves.linearToEaseOut);
      /// You can't have both pomodoro and chronometer at the same time
      if (_selectedPomodoro && !_selectedTimer) {
        selectedTimer = true;
      } else {
        notifyListeners();
      }
    }
  }

  var _shortBreakDuration = 5;

  int get shortBreakDuration => _shortBreakDuration;

  set shortBreakDuration(int shortBreakDuration) {
    if (shortBreakDuration != _shortBreakDuration) {
      this._shortBreakDuration = shortBreakDuration;
      notifyListeners();
    }
  }

  var _longBreakDuration = 15;

  int get longBreakDuration => _longBreakDuration;

  set longBreakDuration(int longBreakDuration) {
    if (longBreakDuration != _longBreakDuration) {
      this._longBreakDuration = longBreakDuration;
      notifyListeners();
    }
  }

  var _repetitions = 4;

  int get repetitions => _repetitions;

  set repetitions(int repetitions) {
    if (repetitions != _repetitions) {
      this._repetitions = repetitions;
      notifyListeners();
    }
  }

  var _remainingRepetitions = 4;

  int get remainingRepetitions => _remainingRepetitions;

  set remainingRepetitions(int remainingRepetitions) {
    if (remainingRepetitions != _remainingRepetitions) {
      this._remainingRepetitions = remainingRepetitions;
      notifyListeners();
    }
  }

  var _create = true;

  bool get create => _create;

  set create(bool create) {
    if (create != _create) {
      this._create = create;
      notifyListeners();
    }
  }

  var _activities = false;

  bool get activities => _activities;

  set activities(bool activities) {
    if (activities != _activities) {
      this._activities = activities;
      notifyListeners();
    }
  }

  var _sounds = false;

  bool get sounds => _sounds;

  set sounds(bool sounds) {
    if (sounds != _sounds) {
      this._sounds = sounds;
      notifyListeners();
    }
  }

  void setNewSettings({required int shortBreak, required int longBreak, required int repetitions, required bool timer, required bool deep}) {
    this.shortBreakDuration = shortBreak;
    this.longBreakDuration = longBreak;
    this.repetitions = repetitions;
    this.selectedTimer = timer;
    this.selectedDeepFocus = deep;
    notifyListeners();
  }
}

/// This model handles the activities

class ActivitiesModel extends ChangeNotifier {

  bool _create = true;

  bool get create => _create;

  set create(bool create) {
    if (create != _create) {
      this._create = create;
      notifyListeners();
    }
  }

  Map<String, dynamic> _activities = {
    "general": <Activity>[],
    "specific": <String, List<Activity>>{}
  };

  Map<String, dynamic> get activities => _activities;

  set activities(Map<String, dynamic> json) {
    this._activities = json;
  }

  String _selectedActivity = "";

  String get selectedActivity => _selectedActivity;

  set selectedActivity(String selectedActivity) {
    if (selectedActivity != _selectedActivity) {
      this._selectedActivity = selectedActivity;
      notifyListeners();
    }
  }

  String _currentGeneral = "";

  String get currentGeneral => _currentGeneral;

  set currentGeneral(String currentGeneral) {
    if (currentGeneral != _currentGeneral) {
      this._currentGeneral = currentGeneral;
      notifyListeners();
    }
  }

  Color _selectedColor = HexColor.fromHex("EF5350");

  Color get selectedColor => _selectedColor;

  set selectedColor(Color selectedColor) {
    if (selectedColor != _selectedColor) {
      this._selectedColor = selectedColor;
      notifyListeners();
    }
  }

  bool _selectedHabit = false;

  bool get selectedHabit => _selectedHabit;

  set selectedHabit(bool selectedHabit) {
    if (selectedHabit != _selectedHabit) {
      this._selectedHabit = selectedHabit;
      notifyListeners();
    }
  }

  String _selectedDays = "M";

  String get selectedDays => _selectedDays;

  set selectedDays(String selectedDays) {
    this._selectedDays = selectedDays;
    notifyListeners();
  }

  int _selectedGoal = 0;

  int get selectedGoal => _selectedGoal;

  set selectedGoal(int goal) {
    this._selectedGoal = goal;
  }

  bool _createSpecific = false;

  bool get createSpecific => _createSpecific;

  set createSpecific(bool createSpecific) {
    if (createSpecific != _createSpecific) {
      this._createSpecific = createSpecific;
      notifyListeners();
    }
  }

  bool _editSpecific = false;

  bool get editSpecific => _editSpecific;

  set editSpecific(bool editSpecific) {
    if (editSpecific != _editSpecific) {
      this._editSpecific = editSpecific;
      notifyListeners();
    }
  }

  /// This method adds an activity to the activities list both here and in the
  /// calendar

  void addActivity(Activity activity, [bool specific = false]) {
    if (!specific) {
      activities["general"].add(activity);
      /// Add the default specific activity
      activities["specific"].putIfAbsent(activity.name, () => [Activity("General", Colors.red[400]!.toHex(), false, "", 1)]);
      addActivityToCalendar(activity);
    } else {
      activities["specific"][currentGeneral].add(activity);
      addActivityToCalendar(activity, specific: true, general: currentGeneral);
    }
    /// Save the activities
    ACTIVITIES_FILE.write(jsonEncode(activities));
    /// Save the new calendar with the added activity
    STATS_FILE.write(jsonEncode({
      "time": timeJson,
      "activities": activitiesJson
    }));
    notifyListeners();
  }

  /// This method removes an activity to the activities list both here and in the
  /// calendar

  void removeActivity(String activity, [bool specific = false]) {
    if (!specific) {
      activities["general"].removeWhere((element) => element.name == activity);
      /// Remove its specific activities
      (activities["specific"] as Map).removeWhere((key, value) => key == activity);
    } else {
      activities["specific"][currentGeneral].removeWhere((element) => element.name == activity);
    }
    removeActivityFromCalendar(activity);
    /// Save the activities
    ACTIVITIES_FILE.write(jsonEncode(activities));
    /// Save the new calendar with added activity
    STATS_FILE.write(jsonEncode({
      "time": timeJson,
      "activities": activitiesJson
    }));
    notifyListeners();
  }

  /// This method edits an existing activity by removing it and substituing it with
  /// the new one both here and in the calendar

  void editActivity({required Activity newActivity, required String oldActivity, bool specific = false}) {
    try {
      if (!specific) {
        final general = activities["general"];
        /// Get the index of the old activity
        final index = general.indexWhere((element) => element.name == oldActivity);
        /// Put the new activity in the same index of the old one
        general.insert(index, newActivity);
        /// Put the specific activities of the old activity into the new one
        activities["specific"].putIfAbsent(newActivity.name, () => List<Activity>.from(activities["specific"][oldActivity]));
        /// Remove the old activity
        if (newActivity.habit == true) {
          if (general.elementAt(index + 1).habit == true) {
            final oldHabits = timeline["habits"][oldActivity];
            timeline["habits"].putIfAbsent(newActivity.name, () => oldHabits);
          } else {
            timeline["habits"].putIfAbsent(newActivity.name, () => []);
          }
          if (newActivity.name != oldActivity) {
            timeline["habits"].remove(oldActivity);
          }
        } else {
          if (general.elementAt(index + 1).habit == true) {
            timeline["habits"].remove(oldActivity);
          }
        }
        TIMELINE_FILE.write(jsonEncode(timeline));
        general.removeAt(index + 1);
      } else {
        /// Get the specific activities of the old activity
        final specificActivities = activities["specific"][getGeneralFromSpecific(oldActivity)];
        /// Get the index of the old activity
        final index = specificActivities.indexWhere((element) => element.name == oldActivity);
        /// Put the new activity in the same index of the old one
        specificActivities.insert(index, newActivity);
        /// Remove the old activity
        specificActivities.removeAt(index + 1);
      }
    } on Error {
      print("An error occurred while editing a preexisting activity");
    }
    /// Save the activities
    ACTIVITIES_FILE.write(jsonEncode(activities));
    /// Save the new calendar with added activity
    STATS_FILE.write(jsonEncode({
      "time": timeJson,
      "activities": activitiesJson
    }));
    notifyListeners();
  }

  /// This method returns the activity with the given name

  Activity getActivityByName(String name, [bool specific = false]) {
    try {
      if (specific)
        return activities["specific"][getGeneralFromSpecific(name)]
          .firstWhere(
            (element) => element.name == name,
            orElse: () {
              return Activity("Error1092", "", false, "", 0);
            });
      else
        return (activities["general"] as List<Activity>)
          .firstWhere(
            (element) => element.name == name,
            orElse: () {
              return Activity("Error1092", "", false, "", 0);
            });
    } on Error {
      return Activity("Error1092", "", false, "", 0);
    }
  }

  /// This method returns the general activity of a specific one

  String getGeneralFromSpecific(String name) {
    for (MapEntry<String, List<Activity>> entries in activities["specific"].entries) {
      for (Activity activity in entries.value) {
        if (activity.name == name) return entries.key;
      }
    }
    return "Error1092";
  }

  /// This method returns whether the given activity is specific or not

  bool isActivitySpecific(String name) {
    for (Activity activity in activities["general"]) {
      if (activity.name == name) return false;
    }
    return true;
  }
}

/// This model handles the statistics

class StatisticsModel extends ChangeNotifier {

  DateTime _selected = DateTime.now();

  DateTime get selected => _selected;

  set selected(DateTime selected) {
    if (selected != _selected) {
      this._selected = selected;
      notifyListeners();
    }
  }

  String _period = "Day";

  String get period => _period;

  set period(String period) {
    if (period != _period) {
      this._period = period;
      notifyListeners();
    }
  }
}