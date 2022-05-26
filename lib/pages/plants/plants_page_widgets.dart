import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final plantNames = [
  "basic",
  "apple",
  "cactus",
  "hibiscus",
  "violet",
  "tulip"
];

final plantAppearanceNames = (BuildContext context) => [
  AppLocalizations.of(context)!.plant1,
  AppLocalizations.of(context)!.plant2,
  AppLocalizations.of(context)!.plant3,
  AppLocalizations.of(context)!.plant4,
  AppLocalizations.of(context)!.plant5,
  AppLocalizations.of(context)!.plant6,
];

final plantsPrices = [
  100,
  150,
  175,
  200,
  225,
  250
];

final plantsDescriptions = (BuildContext context) => [
  AppLocalizations.of(context)!.plant1Desc,
  AppLocalizations.of(context)!.plant2Desc,
  AppLocalizations.of(context)!.plant3Desc,
  AppLocalizations.of(context)!.plant4Desc,
  AppLocalizations.of(context)!.plant5Desc,
  AppLocalizations.of(context)!.plant6Desc,
];

var plantsUnlocked = [];