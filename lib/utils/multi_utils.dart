import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:focus/files/files.dart';
import 'package:focus/pages/forest/forest_page.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/pages/sounds/sounds_page_widgets.dart';
import 'package:focus/utils/coins_utilities.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../main.dart';
import 'data_utils.dart';
import 'notifications_utils.dart';

ValueNotifier<String> username = ValueNotifier("Guest");

ValueNotifier<List<String>> roomCompanions = ValueNotifier(List.empty(growable: true));

ValueNotifier<String> profilePic = ValueNotifier("");

bool profilePicLoaded = false;

int lastEdit = 0;

Future<String> createRoom(BuildContext context) async {
  String code = generateRoomCode(6);
  final a = getEmail(context);
  await FirebaseMessaging.instance.subscribeToTopic(code);
  addCompanion(a!);
  roomCompanions.notifyListeners();
  key.value = code;
  return code;
}

void addCompanion(String email) {
  final value = roomCompanions.value;
  if (value.contains(email)) {
    return;
  }
  roomCompanions.value.add(email);
  roomCompanions.notifyListeners();
}

void removeCompanion(String email) {
  final value = roomCompanions.value;
  if (!value.contains(email)) {
    return;
  }
  roomCompanions.value.remove(email);
  roomCompanions.notifyListeners();
}

String generateRoomCode(int length) {
  const _chars = 'AaBbCcDdEeFfGgHhiJjKkLMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

String generateRandomEmail() {
  final temp = generateRoomCode(9);
  /*
  if ((await FirebaseFirestore.instance.collection("users").doc("$temp@focus.com").get()).exists) {
    return generateRandomEmail();
  }
   */
  return "$temp@focus.com".toLowerCase();
}

String generateRandomPassword() {
  return "${generateRoomCode(7)}";
}

String? getEmail(BuildContext context) {
  final auth = FirebaseAuth.instance.currentUser;
  if (auth == null) {
    Future.delayed(Duration(milliseconds: 100), () => Navigator.pushReplacementNamed(context, "/auth"));
    flutterLocalNotificationsPlugin.show(
        1111,
        AppLocalizations.of(context)!.errorWithAccount,
        AppLocalizations.of(context)!.errorWithAccountSub,
        platformChannelSpecifics
    );
    return "null";
  }
  return auth.email;
}

void setUsername(String newUsername) {
  username.value = newUsername;
  PROFILE_FILE.write(jsonEncode({
    "email": FirebaseAuth.instance.currentUser?.email,
    "lastEdit": lastEdit,
    "username": newUsername,
    "coins": coins,
    "realTrees": realTrees,
    "plants": plantsUnlocked,
    "sounds": soundsUnlocked,
    "lang": locale.value.languageCode,
    "lastDataUpdate": lastDataUpdate
  }));
}

String minutesToHours(int total) {
  int hours = total ~/ 60;
  int minutes = total - hours * 60;
  if (hours == 0) {
    return "${total}m";
  }
  if (minutes == 0) {
    return "${hours}h";
  }
  return "${hours}h and ${total - hours * 60}m";
}

Future<void> signWithGoogle(BuildContext context, bool register) async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  // Once signed in, return the UserCredential
  final user = await FirebaseAuth.instance.signInWithCredential(credential);
  final a = await FirebaseFirestore.instance.collection("users").doc(getEmail(context)).get();
  void saveUser() {
    if (!a.exists) {
      FirebaseFirestore.instance.collection("users").doc(getEmail(context)).set(
          {
            "username": user.user!.displayName,
            "image": user.user!.photoURL,
            "success": 0,
            "failures": 0,
            "minutes": 0,
            "friends": [],
            "received": [],
            "sent": [],
            "realTrees": 0,
            "plants": ["basic"],
            "sounds": ["rain"],
            "premium": false
          });
      PROFILE_FILE.write(jsonEncode({
        "email": FirebaseAuth.instance.currentUser?.email,
        "lastEdit": lastEdit,
        "username": user.user?.displayName != null ? "Guest" : user.user?.displayName,
        "coins": coins,
        "realTrees": 0,
        "plants": ["basic"],
        "sounds": ["rain"],
        "lang": locale.value.languageCode,
        "lastDataUpdate": lastDataUpdate
      }));
    } else {
      PROFILE_FILE.write(jsonEncode({
        "email": FirebaseAuth.instance.currentUser?.email,
        "lastEdit": lastEdit,
        "username": user.user?.displayName != null ? "Guest" : user.user?.displayName,
        "coins": coins,
        "realTrees": a.get("realTrees"),
        "plants": a.get("plants"),
        "sounds": a.get("sounds"),
        "lang": locale.value.languageCode,
        "lastDataUpdate": lastDataUpdate
      }));
    }
  }
  try {
    final b = await PROFILE_FILE.read();
    final json = jsonDecode(b);
    final wasGuest = json["guest"].contains("@focus.com");
    if (wasGuest && register) {
      final oldUser = await FirebaseFirestore.instance.collection("users").doc(json["email"]).get();
      if (!a.exists) {
        final success = oldUser.get("success");
        final failures = oldUser.get("failures");
        final minutes = oldUser.get("minutes");
        final friends = oldUser.get("friends");
        final received = oldUser.get("received");
        final sent = oldUser.get("success");
        FirebaseFirestore.instance.collection("users").doc(getEmail(context)).set(
            {
              "username": json["username"],
              "image": user.user!.photoURL,
              "success": success != null ? success : 0,
              "failures": failures != null ? failures : 0,
              "minutes": minutes != null ? minutes : 0,
              "friends": friends != null ? friends : [],
              "received": received != null ? received : [],
              "sent": sent != null ? sent : [],
              "realTrees": 0,
              "plants": json["plants"],
              "sounds": json["sounds"],
              "premium": false
            });
        PROFILE_FILE.write(jsonEncode({
          "email": FirebaseAuth.instance.currentUser?.email,
          "lastEdit": lastEdit,
          "username": user.user?.displayName != null ? "Guest" : user.user?.displayName,
          "coins": coins,
          "realTrees": realTrees,
          "plants": json["plants"],
          "sounds": json["sounds"],
          "lang": locale.value.languageCode,
          "lastDataUpdate": lastDataUpdate
        }));
      } else {
        PROFILE_FILE.write(jsonEncode({
          "email": FirebaseAuth.instance.currentUser?.email,
          "lastEdit": lastEdit,
          "username": user.user?.displayName != null ? "Guest" : user.user?.displayName,
          "coins": coins,
          "realTrees": a.get("realTrees"),
          "plants": a.get("plants"),
          "sounds": a.get("sounds"),
          "lang": locale.value.languageCode,
          "lastDataUpdate": lastDataUpdate
        }));
      }
    } else {
      saveUser();
    }
  } catch (e) {
    saveUser();
  }
  Navigator.pushNamed(context, "/splash");
}

void signInWithApple(BuildContext context, bool register) async {
  final result = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]
  );
  final oAuthProvider = OAuthProvider('apple.com');
  final credential = oAuthProvider.credential(
      idToken: result.identityToken,
      accessToken: result.authorizationCode
  );
  final user = await FirebaseAuth.instance.signInWithCredential(credential);
  final a = await FirebaseFirestore.instance.collection("users").doc(getEmail(context)).get();
  final temp = user.user;
  void saveUser() {
    if (!a.exists) {
      FirebaseFirestore.instance.collection("users").doc(getEmail(context)).set(
          {
            "username": temp?.displayName == null ? "Guest": temp!.displayName,
            "image": "",
            "success": 0,
            "failures": 0,
            "minutes": 0,
            "friends": [],
            "received": [],
            "sent": [],
            "realTrees": 0,
            "plants": ["basic"],
            "sounds": ["rain"],
            "premium": false
          });
      PROFILE_FILE.write(jsonEncode({
        "email": FirebaseAuth.instance.currentUser?.email,
        "lastEdit": lastEdit,
        "username": user.user?.displayName != null ? "Guest" : user.user?.displayName,
        "coins": coins,
        "realTrees": 0,
        "plants": ["basic"],
        "sounds": ["rain"],
        "lang": locale.value.languageCode,
        "lastDataUpdate": lastDataUpdate
      }));
    } else {
      PROFILE_FILE.write(jsonEncode({
        "email": FirebaseAuth.instance.currentUser?.email,
        "lastEdit": lastEdit,
        "username": user.user?.displayName != null ? "Guest" : user.user?.displayName,
        "coins": coins,
        "realTrees": a.get("realTrees"),
        "plants": a.get("plants"),
        "sounds": a.get("sounds"),
        "lang": locale.value.languageCode,
        "lastDataUpdate": lastDataUpdate
      }));
    }
  }
  try {
    final b = await PROFILE_FILE.read();
    final json = jsonDecode(b);
    final wasGuest = json["guest"].contains("@focus.com");
    if (wasGuest && register) {
      final oldUser = await FirebaseFirestore.instance.collection("users").doc(json["email"]).get();
      if (!a.exists) {
        final success = oldUser.get("success");
        final failures = oldUser.get("failures");
        final minutes = oldUser.get("minutes");
        final friends = oldUser.get("friends");
        final received = oldUser.get("received");
        final sent = oldUser.get("success");
        FirebaseFirestore.instance.collection("users").doc(getEmail(context)).set(
            {
              "username": json["username"],
              "image": "",
              "success": success != null ? success : 0,
              "failures": failures != null ? failures : 0,
              "minutes": minutes != null ? minutes : 0,
              "friends": friends != null ? friends : [],
              "received": received != null ? received : [],
              "sent": sent != null ? sent : [],
              "realTrees": 0,
              "plants": json["plants"],
              "sounds": json["sounds"],
              "premium": false
            });
        PROFILE_FILE.write(jsonEncode({
          "email": FirebaseAuth.instance.currentUser?.email,
          "lastEdit": lastEdit,
          "username": user.user?.displayName != null ? "Guest" : user.user?.displayName,
          "coins": coins,
          "realTrees": realTrees,
          "plants": json["plants"],
          "sounds": json["sounds"],
          "lang": locale.value.languageCode,
          "lastDataUpdate": lastDataUpdate
        }));
      } else {
        PROFILE_FILE.write(jsonEncode({
          "email": FirebaseAuth.instance.currentUser?.email,
          "lastEdit": lastEdit,
          "username": user.user?.displayName != null ? "Guest" : user.user?.displayName,
          "coins": coins,
          "realTrees": a.get("realTrees"),
          "plants": a.get("plants"),
          "sounds": a.get("sounds"),
          "lang": locale.value.languageCode,
          "lastDataUpdate": lastDataUpdate
        }));
      }
    } else {
      saveUser();
    }
  } catch (e) {
    saveUser();
  }
  Navigator.pushNamed(context, "/splash");
}

Future<void> unsubscribe(BuildContext context) async {
  final token = await FirebaseMessaging.instance.getToken();
  var response = await http.get(
    Uri.parse("https://iid.googleapis.com/iid/info/${token}?details=true"),
    headers: {'Authorization':'key =AAAAVgN7xWg:APA91bEut_gx_KN1r8Mwczl4dQOWaw4oU4uTTeRjAMmPceQZpyPDa1NHMQUOBnuNxWkSsof7vV_ldhv6O0hB4tkzDtXDkf1y3xfb0FmhPGSfByUKQhFfJPZ-nAiM4fwSWNAseto2Ak6N'},
  );
  Map<String, dynamic>? rel = (jsonDecode(response.body))['rel'];
  if (rel == null) return;
  for (String key in rel["topics"].keys) {
    await Future.delayed(Duration(milliseconds: 100));
    try {
      if (key != topicEmail(getEmail(context))) FirebaseMessaging.instance.unsubscribeFromTopic(key);
    } catch (e) {}
  }
}

void savePlant(String plant, BuildContext context) async {
  FirebaseFirestore.instance.collection("users").doc(getEmail(context)).update({
    "plants": FieldValue.arrayUnion([plant]),
  });
}

void saveSound(String sound, BuildContext context) async {
  FirebaseFirestore.instance.collection("users").doc(getEmail(context)).update({
    "sounds": FieldValue.arrayUnion([sound])
  });
}

void loadUserNews(BuildContext context) {
  void loadUser() async {
    /// Save from the database
    try {
      final a = await FirebaseFirestore.instance.collection("users").doc(getEmail(context)).get();
      if (a.get("realTrees") > realTrees) realTrees = a.get("realTrees");
      a.get("plants").forEach((element) {
        if (!plantsUnlocked.contains(element)) plantsUnlocked.add(element);
      });
      a.get("sounds").forEach((element) {
        if (!soundsUnlocked.contains(element)) soundsUnlocked.add(element);
      });
      lastEdit = DateTime.now().millisecondsSinceEpoch;
      PROFILE_FILE.write(jsonEncode({
        "email": FirebaseAuth.instance.currentUser?.email,
        "lastEdit": lastEdit,
        "username": username.value,
        "coins": coins,
        "realTrees": realTrees,
        "plants": plantsUnlocked,
        "sounds": soundsUnlocked,
        "lang": locale.value.languageCode,
        "lastDataUpdate": lastDataUpdate
      }));
    } catch (e) {
      print(e);
    }
  }
  if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastEdit)).inDays <= 3) {
    return;
  }
  loadUser();
}

String multiText(List<String> data, BuildContext context) {
  if (data.length == 0) return "";
  if (data.length == 1) {
    return AppLocalizations.of(context)!.waitingForOthers;
  } else if (data.length == 2) {
    return "You and ${data.elementAt(0)}";
  } else {
    return "You, ${data.elementAt(1)} and ${data.length - 2} other";
  }
}

String topicEmail(String? email) {
  if (email == null) return "";
  return email
      .replaceAll("@", "")
      .replaceAll(".", "")
      .replaceAll("_", "")
      .replaceAll("-", "");
}