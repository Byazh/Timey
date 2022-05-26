import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus/files/files.dart';
import 'package:focus/pages/forest/forest_page.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/pages/sounds/sounds_page_widgets.dart';
import 'package:focus/utils/multi_utils.dart';

import '../main.dart';
import 'data_utils.dart';

var coins = 0;

void addCoins(int amount) {
  coins += amount;
  PROFILE_FILE.write(jsonEncode({
    "email": FirebaseAuth.instance.currentUser?.email,
    "lastEdit": lastEdit,
    "coins": coins,
    "username": username.value,
    "realTrees": realTrees,
    "plants": plantsUnlocked,
    "sounds": soundsUnlocked,
    "lang": locale.value.languageCode,
    "lastDataUpdate": lastDataUpdate
  }));
}

void removeCoins(int amount) {
  coins -= amount;
  PROFILE_FILE.write(jsonEncode({
    "email": FirebaseAuth.instance.currentUser?.email,
    "lastEdit": lastEdit,
    "coins": coins,
    "username": username.value,
    "realTrees": realTrees,
    "plants": plantsUnlocked,
    "sounds": soundsUnlocked,
    "lang": locale.value.languageCode,
    "lastDataUpdate": lastDataUpdate
  }));
}

int calculateAmount(int minutes) {
  int amount = 0;
  amount = (0.3 * minutes).round();
  return amount;
}

String randomCoinNumber = "TeRjAMmPceQZpyPDa1NHMQUOBnuNxWkSsof7vV_ldhv6O0hB4tkzDtXDkf1y3xfb0FmhPGSfB";