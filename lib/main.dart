import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:focus/pages/home/home_page.dart';
import 'package:focus/utils/messages_utils.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'pages/splash/splash_page.dart';
import 'pages/auth/auth_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/sign_up_page.dart';
import 'pages/statistics/statistics_page.dart';
import 'pages/plants/plants_page.dart';
import 'pages/sounds/sounds_page.dart';
import 'pages/activities/activities_page.dart';
import 'pages/calendar/calendar_page.dart';
import 'pages/friends/friends_page.dart';
import 'pages/forest/forest_page.dart';
import 'package:focus/pages/forest/forest_page_widgets.dart';
import 'pages/settings/settings_page.dart';

import 'models/models.dart';
import 'utils/data_utils.dart';

const version = 1.1;

/// The width and the height of the device

late double width, height;

/// The current locale of the application

var locale = ValueNotifier(Locale("en"));

/// This is the main method of the application

void main() async {
  await initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SingleMultipleModel()),
        ChangeNotifierProvider(create: (_) => TimerStatusModel()),
        ChangeNotifierProvider(create: (_) => TimerModel()),
        ChangeNotifierProvider(create: (_) => MenuModel()),
        ChangeNotifierProvider(create: (_) => ActivitiesModel()),
        ChangeNotifierProvider(create: (_) => StatisticsModel())
      ],
      child: _Application()
    )
  );
  /// write here
}
/// This class represents the ancestor widget of the application

class _Application extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    /// Load data from the local files
    loadData(context);
    return ValueListenableBuilder<Locale>(
      valueListenable: locale,
      builder: (BuildContext context, value, Widget? child) {
        return Material(
            child: ValueListenableBuilder<Locale>(
              valueListenable: locale,
              builder: (context, value, child) {
                return MaterialApp(
                    title: "Timey",
                    theme: ThemeData(
                        brightness: Brightness.light,
                        backgroundColor: Color.fromRGBO(80, 163, 135, 1),
                        scaffoldBackgroundColor: Color.fromRGBO(251, 246, 181, 1),
                        primaryColor: Color.fromRGBO(146, 209, 120, 1),
                        accentColor: Colors.white,
                        fontFamily: "Euclid"
                    ),
                    localizationsDelegates: [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    locale: value,
                    supportedLocales: locales,
                    initialRoute: "/splash",
                    routes: {
                      "/splash":  (_) => SplashPage(),
                      "/home":    (_) => HomePage(),
                      "/auth":    (_) => AuthPage(),
                      "/login":   (_) => LoginPage(),
                      "/signup":  (_) => SignUpPage(),
                      "/payment": (_) => PaymentPage(),
                      "0": (_) => StatisticsPage(),
                      "1": (_) => PlantsPage(),
                      "2": (_) => SoundsPage(),
                      "3": (_) => ActivitiesPage(),
                      "4": (_) => CalendarPage(),
                      "5": (_) => GroupsPage(),
                      "6": (_) => ForestPage(),
                      "7": (_) => SettingsPage(),
                    }
                );
              }
            )
        );
      }
    );
  }
}

/// This method initializes all the elements necessary to the correct start of
/// the application

Future<void> initialize() async {
  /// In order to apply changes before the app is run
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_live_51KgxMyI1sDHEjElumWvURs8wb1LtdODLlQcxbt5jZdcnEYBScDYyd70bEbjVOqQM7bAAmjdaKGJtX21DL65slk9R00XQB6AtFC";
  Stripe.merchantIdentifier = "merchant.com.focus.mobile.focus.unique";
  /// Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AAAAVgN7xWg:APA91bEut_gx_KN1r8Mwczl4dQOWaw4oU4uTTeRjAMmPceQZpyPDa1NHMQUOBnuNxWkSsof7vV_ldhv6O0hB4tkzDtXDkf1y3xfb0FmhPGSfByUKQhFfJPZ-nAiM4fwSWNAseto2Ak6N",
        appId: Platform.isIOS
            ? "1:369425630568:ios:38ca8fd87cebb990d802dd"
            : "1:369425630568:android:88f8a2477f8c7f80d802dd",
        messagingSenderId: "369425630568",
        projectId: "focus-6b0cb"
      )
    );
  } catch (e) {}
  await FirebaseAppCheck.instance.activate();
}