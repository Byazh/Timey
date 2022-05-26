import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import 'package:focus/pages/activities/activities_page_widgets.dart';

import 'package:focus/models/models.dart';
import 'package:focus/utils/color_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This class represents the activities page, which lets the user create, delete
/// or edit his activities

class ActivitiesPage extends StatelessWidget {

  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ActivitiesMenuWidget(
        body: Scaffold(
          backgroundColor: Color.fromRGBO(80, 163, 135, 1.0),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(height / 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBar(
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor:  Color.fromRGBO(80, 163, 135, 1.0),
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
                  title: Text(
                    AppLocalizations.of(context)!.activities,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 52.3,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500
                    )
                  )
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Container(
            padding: EdgeInsets.all(height / 46),
            width: height / 8.13,
            height: height / 8.13,
            child: FloatingActionButton(
              backgroundColor: Color.fromRGBO(80, 163, 135, 1.0),
              onPressed: () {
                /// Defines the default activity settings
                final model = Provider.of<ActivitiesModel>(context, listen: false);
                model.create = true;
                model.createSpecific = false;
                model.editSpecific = false;
                model.selectedColor = HexColor.fromHex("EF5350");
                model.selectedHabit = false;
                model.selectedDays = "";
                model.selectedGoal = 15;
                textController.text = "";
                /// Open the panel
                panelController.animatePanelToPosition(
                  0.65,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linearToEaseOut
                );
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: height / 29.3
              )
            )
          ),
          body: Container(
            margin: EdgeInsets.only(top: height / 73.2),
            decoration: BoxDecoration(
              color: Color.fromRGBO(251, 246, 181, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(height / 21),
                topRight: Radius.circular(height / 21)
              )
            ),
            child: Consumer<ActivitiesModel>(
              builder: (context, model, child) {
                final activities = model.activities;
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width / 10.28,
                    vertical: height / 48.8
                  ),
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: activities["general"].length,
                    itemBuilder: (context, index) {

                      final activity = activities["general"][index];
                      final specificActivities = activities["specific"][activity.name];
                      return Column(
                        children: [
                          ActivityWidget(
                            name: activity.name,
                            color: HexColor.fromHex(activity.color)
                          ),
                          /// If the default specific activity isn't the only one, then
                          /// display the other specific activities
                          /*
                          if (specificActivities.length != 1) ...[
                            Divider(
                                color: Color.fromRGBO(37, 76, 64, 0.25),
                                height: height / 350
                            ),
                            SubActivitiesList(
                              activity.name
                            ),
                            Divider(
                                color: Color.fromRGBO(37, 76, 64, 0.25),
                                height: height / 350
                            )
                          ],
                           */
                          if (specificActivities != null && specificActivities.length == 1)
                            Container(
                               color: Color.fromRGBO(37, 76, 64, 0.1),
                               height: 1,
                              width: width,
                      )
                        ]
                      );
                    }
                  )
                );
              }
            )
          )
        )
      )
    );
  }
}