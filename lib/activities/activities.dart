import 'package:json_annotation/json_annotation.dart';

/// This class represents an activity

@JsonSerializable(explicitToJson: true)
class Activity {

  /// The name of the activity
  final String name;
  /// The color of the activity
  final String color;
  /// Whether the activity is a recurring habit
  final bool habit;
  /// The days in which the habit is repeated in
  final String days;
  /// The daily goal of the activity if it's a habit
  final int goal;

  Activity(this.name, this.color, this.habit, this.days, this.goal);

  factory Activity.fromJson(Map<String, dynamic> json) =>
      Activity(json["name"], json["color"], json["habit"], json["days"], json["goal"]);

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "color": this.color,
      "habit": this.habit,
      "days": this.days,
      "goal": this.goal
    };
  }
}