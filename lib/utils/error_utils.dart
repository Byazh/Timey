import 'package:focus/utils/notifications_utils.dart';

void sendErrorNotificationActivities() {
  flutterLocalNotificationsPlugin.show(
      1092,
      "An error has occurred while managing your activities!",
      "Because the app is still in beta, there might be some bugs! If the app shows persistent problems, please reinstall it or wait for the next update!",
      platformChannelSpecifics
  );
}

void sendErrorNotificationData() {
  flutterLocalNotificationsPlugin.show(
      1092,
      "An error has occurred while loading your previous data!",
      "Because the app is still in beta, there might be some bugs! If the app shows persistent problems, please reinstall it or wait for the next update!",
      platformChannelSpecifics
  );
}