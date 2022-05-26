import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:focus/main.dart';
import 'package:focus/pages/welcome/welcome_page.dart';
import 'package:focus/pages/home/home_page_widgets.dart';

/// The titles of the welcome pages

final titles = (BuildContext context) => [
  AppLocalizations.of(context)!.welcomeTitle1,
  AppLocalizations.of(context)!.welcomeTitle2,
  AppLocalizations.of(context)!.welcomeTitle3,
  AppLocalizations.of(context)!.welcomeTitle4,
  AppLocalizations.of(context)!.welcomeTitle5
];

/// The descriptions of the welcome pages

final descriptions = (BuildContext context) => [
  AppLocalizations.of(context)!.welcomeDesc1,
  AppLocalizations.of(context)!.welcomeDesc2,
  AppLocalizations.of(context)!.welcomeDesc3,
  AppLocalizations.of(context)!.welcomeDesc4,
  AppLocalizations.of(context)!.welcomeDesc5
];

/// This class represents a single welcome page

class WelcomeSlide extends StatelessWidget {

  final index;

  const WelcomeSlide(this.index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "\n${titles(context)[index]}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromRGBO(44, 106, 85, 1.0),
              fontSize: height / 30,
              fontWeight: FontWeight.w700
            )
          ),
          Image.asset(
            "resources/images/welcome/$index.png",
            height: height / 2.5
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width / 30),
            child: Text(
              descriptions(context)[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(44, 106, 85, 0.5411764705882353),
                fontSize: height / 40,
                fontWeight: FontWeight.w500
              )
            )
          ),
          CustomButton(
            text: index == 4
              ? "  ${AppLocalizations.of(context)!.start}  "
              : "  ${AppLocalizations.of(context)!.next}  " ,
            textSize: height / 37,
            color: Color.fromRGBO(84, 172, 142, 1.0),
            onPressed: () async {
              if (index < 4) {
                controller.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linearToEaseOut
                );
              } else {
                Future.delayed(Duration(milliseconds: 100), () => Navigator.pushReplacementNamed(context, "/auth"));
              }
            }
          )
        ]
      ),
    );
  }
}