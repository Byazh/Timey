import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final soundAppearanceNames = (BuildContext context) => [
  AppLocalizations.of(context)!.sound1,
  AppLocalizations.of(context)!.sound2,
  AppLocalizations.of(context)!.sound3,
  AppLocalizations.of(context)!.sound4,
  AppLocalizations.of(context)!.sound5,
  AppLocalizations.of(context)!.sound6,
  AppLocalizations.of(context)!.sound7,
];

final soundPrices = [
  100,
  150,
  175,
  200,
  225,
  250,
  275
];

final soundDescriptions = (BuildContext context) => [
  AppLocalizations.of(context)!.sound1Desc,
  AppLocalizations.of(context)!.sound2Desc,
  AppLocalizations.of(context)!.sound3Desc,
  AppLocalizations.of(context)!.sound4Desc,
  AppLocalizations.of(context)!.sound5Desc,
  AppLocalizations.of(context)!.sound6Desc,
  AppLocalizations.of(context)!.sound7Desc,
];

var soundsUnlocked = ["rain"];
