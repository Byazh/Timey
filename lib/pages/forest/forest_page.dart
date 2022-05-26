import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus/files/files.dart';
import 'package:focus/pages/forest/forest_page_widgets.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:focus/utils/coins_utilities.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../utils/data_utils.dart';
import '../../utils/multi_utils.dart';
import '../plants/plants_page_widgets.dart';
import '../sounds/sounds_page_widgets.dart';

int realTrees = 0;

class ForestPage extends StatelessWidget {

  const ForestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 250, 192, 1.0),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(height / 6), bottomRight: Radius.circular(height / 6)
              )
            ),
            backgroundColor: Theme.of(context).backgroundColor,
            centerTitle: true,
            leading: GestureDetector(
                child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: height / 35
                ),
                onTap: () {
                  Navigator.pop(context);
                }
            ),
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: height / 2.35,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              title: Text(
                  AppLocalizations.of(context)!.plantRealTree,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: height / 45,
                  fontWeight: FontWeight.w600
                ),
              ),
              background: ClipRRect(
                borderRadius: BorderRadius.only(
                   bottomLeft: Radius.circular(height / 14.6), bottomRight: Radius.circular(height / 14.6)
                ),
                child: Image.asset(
                  "resources/images/general/real-tree.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: width / 15.6, vertical: height / 24.4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: height / 33.3),
                          child: Column(
                            children: [
                              Text(
                                  "${AppLocalizations.of(context)!.decreaseFootprint}\n",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: height / 46,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.75)
                                ),
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: "$realTrees",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: height / 33,
                                        fontWeight: FontWeight.w600
                                    ),
                                    children: [
                                      TextSpan(
                                          text: "\n${AppLocalizations.of(context)!.plantedByYou}",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: height / 61,
                                              fontWeight: FontWeight.w400
                                          )
                                      )
                                    ]
                                ),
                              )
                            ],
                          ),
                        );
                      }
                      var a = [
                        AppLocalizations.of(context)!.forestSub1,
                        AppLocalizations.of(context)!.forestSub2,
                        AppLocalizations.of(context)!.forestSub3,
                        AppLocalizations.of(context)!.forestSub4,
                        AppLocalizations.of(context)!.forestSub5
                      ];
                      if (index == 3) return GestureDetector(
                        onTap: () {
                          launch("https://trees.org");
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: height / 25),
                          child: Image.asset(
                            "resources/images/general/trees_for_future.png",
                            height: height / 12
                          )
                        ),
                      );
                        return GestureDetector(
                          onTap: () {
                            if (index == 5) {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return PaymentPage(info: true);
                              }
                            ));
                          }
                          },
                          child: Text(
                          a[index - 1],
                       textAlign: index == 5 ? TextAlign.center : TextAlign.justify,
                          style: TextStyle(
                            fontSize: height / 57,
                            fontWeight: index == 5 ? FontWeight.w500 : FontWeight.w400
                          )
                      ),
                        );
                },
                childCount: 6
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        width: width,
        height: height / 9.75,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(topRight: Radius.circular(height / 24.4), topLeft: Radius.circular(height / 24.4))
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 15, vertical: height / 146),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.plantNow,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: height / 52
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.itCosts2500}  ",
                        style: TextStyle(
                            color: Colors.white,
                          fontSize: height / 61,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                      Icon(
                        Icons.monetization_on,
                        color: Colors.yellow,
                        size: height / 61,
                      )
                    ],
                  )
                ],
              ),
              PlantRealButton()
            ],
          ),
        ),
      ),
    );
  }
}

class PlantRealButton extends StatefulWidget {
  const PlantRealButton({Key? key}) : super(key: key);

  @override
  _PlantRealButtonState createState() => _PlantRealButtonState();
}

class _PlantRealButtonState extends State<PlantRealButton> {

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: AppLocalizations.of(context)!.plant,
      loading: loading,
      onPressed: () async {
        setState(() {
          loading = true;
        });
      final email = getEmail(context);
      if (email == null || email.contains("@focus.com")) {
        setState(() {
          loading = false;
        });
        showFadingDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return CustomDialogBase(
                  titleIcon: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 35,
                  ),
                  body: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: width / 45, right: width / 45, top: height / 24.5, bottom: height / 146),
                        child: Text(
                          AppLocalizations.of(context)!.youMustBeLogged,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height / 48,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: width / 20, right: width / 20, top: height / 150, bottom: height / 50),
                        child: Text(
                          AppLocalizations.of(context)!.youMustBeLoggedSub,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height / 53,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButton(
                              text: AppLocalizations.of(context)!.cancel,
                              color: Colors.grey.withOpacity(0.6),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          CustomButton(
                              text: AppLocalizations.of(context)!.confirm,
                              color: Colors.red,
                              onPressed: () async {
                                Navigator.pushNamed(context, "/auth");
                              })
                        ],
                      ),
                    ],
                  )
              );
            },
            duration: Duration(milliseconds: 500)
        );
      } else {
        final user = await FirebaseFirestore.instance.collection("users").doc(email).get();
        if (user.exists && user.get("premium") == true) {
          if (coins < 2500) {
            showFadingDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => CustomDialogBase(
                    titleIcon: Icon(
                        Icons.monetization_on,
                        color: Colors.yellow,
                        size: height / 21),
                    body: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width / 45, right: width / 45, top: height / 24.5, bottom: height / 146),
                          child: Text(
                           AppLocalizations.of(context)!.notEnoughCoinsPlant,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: height / 48,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width / 24, right: width / 24, top: height / 244, bottom: height / 36),
                          child: Text(
                            AppLocalizations.of(context)!.notEnoughCoinsPlantSub,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: height / 54,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ),
                        CustomButton(
                            text: AppLocalizations.of(context)!.goBack,
                            color: Colors.grey.withOpacity(0.5),
                            textSize: height / 49,
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    )
                ),
                duration: Duration(milliseconds: 500)
            );
          } else if (realTrees >= 5) {
            showFadingDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => CustomDialogBase(
                    titleIcon: Icon(
                        Icons.numbers,
                        color: Colors.white,
                        size: height / 21),
                    body: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width / 45, right: width / 45, top: height / 24.5, bottom: height / 146),
                          child: Text(
                            AppLocalizations.of(context)!.realTreesLimit,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: height / 48,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width / 24, right: width / 24, top: height / 244, bottom: height / 36),
                          child: Text(
                            AppLocalizations.of(context)!.realTreesLimitSub,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: height / 54,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ),
                        CustomButton(
                            text: AppLocalizations.of(context)!.goBack,
                            color: Colors.grey.withOpacity(0.5),
                            textSize: height / 49,
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    )
                ),
                duration: Duration(milliseconds: 500)
            );
          } else {
            FirebaseFirestore.instance.collection("general").doc("real_trees_planters").update({
              "$email": FieldValue.arrayUnion([DateTime.now().toIso8601String()])
            });
            realTrees += 1;
            coins -= 2500;
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
          }
        } else {
          Navigator.pushNamed(context, "/payment");
        }
        setState(() {
          loading = false;
        });
      }
    });
  }
}


class StatText extends StatelessWidget {

  final int number;
  final String statistic;

  const StatText({Key? key, required this.number, required this.statistic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: Colors.black87,
          fontSize: height / 33,
          fontWeight: FontWeight.w600
        ),
        children: [
          TextSpan(
            text: "\n$statistic",
            style: TextStyle(
              color: Colors.black87,
              fontSize: height / 66,
              fontWeight: FontWeight.w400
            )
          )
        ]
      ),
    );
  }
}