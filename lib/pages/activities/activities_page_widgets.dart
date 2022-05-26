import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import 'package:focus/pages/home/home_page_widgets.dart';

import 'package:focus/activities/activities.dart';
import 'package:focus/stats/stats.dart';
import 'package:focus/timeline/timeline.dart';
import 'package:focus/models/models.dart';
import 'package:focus/utils/color_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/panel.dart';

/// This is the controller of the below panel

final panelController = PanelController();

/// This class represents a widget containing the activity name and color which is
/// shown in the activities page

class ActivityWidget extends StatelessWidget {

  final String name;
  final Color color;
  final bool general;

  const ActivityWidget({Key? key, required this.name, required this.color, this.general = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ActivitiesModel>(context, listen: false);
    return GestureDetector(
      child: Container(
        height: height / 12.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: height / 91,
                ),
                SizedBox(
                  width: width / 20,
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: Color.fromRGBO(49, 88, 75, 1.0),
                    fontSize: height / 48.8,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
            Row(
              children: [
                /*
                general
                    ? IconButton(
                    icon: Icon(
                      Icons.add,
                      size: height / 35,
                      color: Color.fromRGBO(37, 76, 64, 0.8)
                    ),
                    onPressed: () {
                      model.create = false;
                      model.createSpecific = true;
                      model.selectedActivity = name;
                      model.currentGeneral = name;
                      model.selectedHabit = false;
                      textController.text = "";
                      panelController.animatePanelToPosition(
                        0.65,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.linearToEaseOut
                      );
                    })
                    : Container(width: 0),
                 */
                Icon(
                    Icons.edit,
                    color: Color.fromRGBO(37, 76, 64, 0.8),
                    size: height / 40
                )
              ]
            )
          ]
        )
      ),
      onTap: () {
        model.create = false;
        model.createSpecific = false;
        model.editSpecific = !general;
        model.selectedActivity = name;
        if (general) model.currentGeneral = name;
        else model.currentGeneral = model.getGeneralFromSpecific(name);
        final activity = model.getActivityByName(name, !general);
        model.selectedGoal = activity.goal;
        model.selectedColor = HexColor.fromHex(activity.color);
        model.selectedHabit = activity.habit;
        model.selectedDays = activity.days;
        textController.text = model.getActivityByName(model.selectedActivity, model.editSpecific).name;
        panelController.animatePanelToPosition(
            model.selectedHabit ? 1 : 0.65,
            duration: Duration(milliseconds: 500),
            curve: Curves.linearToEaseOut
        );
      },
    );
  }
}

/// This class represents the widget containing the list of specific activities of a
/// general activity

class SubActivitiesList extends StatelessWidget {

  final String name;

  const SubActivitiesList(this.name);

  @override
  Widget build(BuildContext context) {
    final specific = Provider.of<ActivitiesModel>(context, listen: false).activities["specific"][name];
    return Container(
      margin: EdgeInsets.only(bottom: height / 73, left: height / 24),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: specific.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == 0) return Container();
          return ActivityWidget(
            name: specific[index].name,
            color: HexColor.fromHex(specific[index].color),
            general: false
          );
        },
      ),
    );
  }
}

/// This is the controller of the below text editor

final textController = TextEditingController();

/// This class represents the menu opened by clicking the timer. It contains all the
/// options to start the session

class ActivitiesMenuWidget extends StatefulWidget {

  final Widget body;

  const ActivitiesMenuWidget({required this.body});

  @override
  _ActivitiesMenuWidgetState createState() => _ActivitiesMenuWidgetState();
}

/// This class represents the state of the above widget

class _ActivitiesMenuWidgetState extends State<ActivitiesMenuWidget> {

  /// This is the goal of the selected activity
  var goal = Duration(seconds: -1);

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesModel>(
      builder: (context, model, child) {
        /// Whether the text editor is empty
        bool empty = textController.text.isEmpty;
        /// Whether the inserted name has already been used
        bool used =
            textController.text != model.selectedActivity /// It is ok if the name remains the same
         && (model.getActivityByName(textController.text).name != "Error1092" ||  model.getActivityByName(textController.text, true).name != "Error1092"); /// Checks whether a general or specific activity with this name already exists
        return SlidingUpPanel(
          controller: panelController,
          defaultPanelState: PanelState.CLOSED,
          minHeight: 0,
          maxHeight: height * 0.86,
          color: Color.fromRGBO(80, 163, 135, 1),
          /// What's under the menu, which, in our case, is the whole scaffold
          body: child,
          /// Make background darker when opening the menu
          backdropEnabled: true,
          backdropOpacity: 0.4,
          /// The header small draggable line
          header: Container(
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width / 12,
                  child: Divider(
                    color: Colors.white,
                    thickness: 2
                  )
                )
              ]
            )
          ),
          /// The content of the menu
          panel: Container(
            margin: EdgeInsets.only(top: height / 350),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(height / 18)),
              color: Color.fromRGBO(80, 163, 135, 1.0)
            ),
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                Column(
                  children: [
                    TitleMenuText(
                      title: AppLocalizations.of(context)!.name,
                      alignment: Alignment.center,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width / 40.5, vertical: height / 61),
                      height: height / 25,
                      child: TextField(
                        controller: textController,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        cursorColor: Colors.white,
                        onSubmitted: (text) {
                          setState(() {
                            empty = text.isEmpty;
                            used = textController.text != model.selectedActivity && (model.getActivityByName(text).name != "Error1092" ||  model.getActivityByName(text, true).name != "Error1092");
                          });
                          },
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height / 52.4
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.25),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(height / 36),
                            borderSide: BorderSide.none
                          )
                        )
                      )
                    ),
                    SizedBox(height: height / 73),
                    TitleMenuText(
                      title: AppLocalizations.of(context)!.chooseColor,
                      alignment: Alignment.center
                    ),
                    ColorPickerWidget(),
                    GestureDetector(
                      child: TitleMenuText(
                        title: AppLocalizations.of(context)!.habit,
                        alignment: Alignment.center,
                        icon: true
                      ),
                      onTap: () => methodInfo(
                          context,
                          AppLocalizations.of(context)!.infoHabits,
                          AppLocalizations.of(context)!.infoHabitsSub
                      )
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: height / 50),
                      child: CreateSavedWidget(
                        nameOne: AppLocalizations.of(context)!.yes,
                        nameTwo: AppLocalizations.of(context)!.no,
                        width: 3,
                        firstIsActive: model.selectedHabit,
                        onTapFirst: () {
                          panelController.animatePanelToPosition(1, duration: Duration(milliseconds: 1000), curve: Curves.linearToEaseOut);
                          model.selectedHabit = true;
                        },
                        onTapSecond: () {
                          model.selectedHabit = false;
                          panelController.animatePanelToPosition(0.65, duration: Duration(milliseconds: 1000), curve: Curves.linearToEaseOut);
                        }
                      )
                    ),
                    if (model.selectedHabit) ...[
                      GestureDetector(
                        child: TitleMenuText(
                          title: AppLocalizations.of(context)!.days,
                          alignment: Alignment.center,
                          icon: true
                        ),
                        onTap: () => methodInfo(
                            context,
                            AppLocalizations.of(context)!.infoDay,
                            AppLocalizations.of(context)!.infoDaySub
                        )
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: height / 45),
                        child: DaysSelectorWidget()
                      ),
                      GestureDetector(
                        child: TitleMenuText(
                          title: AppLocalizations.of(context)!.dailyGoal,
                          alignment: Alignment.center,
                          icon: true
                        ),
                        onTap: () => methodInfo(
                            context,
                            AppLocalizations.of(context)!.infoGoal,
                            AppLocalizations.of(context)!.infoGoalSub
                        )
                      ),
                      Container(
                        width: width / 1.6,
                        height: height / 7.3,
                        margin: EdgeInsets.symmetric(vertical: height / 35),
                        child: CupertinoTheme(
                        data: CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                          primaryColor: Colors.white,
                          dateTimePickerTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: height / 30
                          ),
                          pickerTextStyle: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: height / 40
                          )
                          )
                        ),
                        child: CupertinoTimerPicker(
                          key: UniqueKey(),
                          onTimerDurationChanged: (duration) {
                            this.goal = duration;
                            },
                          initialTimerDuration: Duration(seconds: model.selectedGoal),
                          mode: CupertinoTimerPickerMode.hm,
                        )
                        )
                      )
                    ],
                    if (!model.selectedHabit) SizedBox(height: height / 49),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!model.create && !model.createSpecific)...[
                          CustomButton(
                            text: AppLocalizations.of(context)!.delete,
                            color: Colors.redAccent.shade100,
                            onPressed: () {
                            model.removeActivity(
                              model.getActivityByName(model.selectedActivity, model.editSpecific).name,
                              model.editSpecific
                            );
                            removeActivityFromCalendar(model.selectedActivity);
                            panelController.close();
                          }
                          ),
                          SizedBox(width: width / 10)
                        ],
                        CustomButton(
                          text: model.create || model.createSpecific
                              ? AppLocalizations.of(context)!.create
                              : AppLocalizations.of(context)!.save,
                          color: !empty && !used ? Color.fromRGBO(161, 228, 163, 0.8) : Colors.grey.withOpacity(0.5),
                          onPressed: !empty && !used ? () {
                            if (model.create || model.createSpecific) {
                              model.addActivity(
                                Activity(
                                  textController.text,
                                  model.selectedColor.toHex(),
                                  model.selectedHabit,
                                  model.selectedDays,
                                  goal.isNegative ? 0 : goal.inSeconds
                                ),
                                model.createSpecific
                              );
                              if (model.selectedHabit) {
                                timeline["habits"].putIfAbsent(textController.text, () => []);
                              }
                              panelController.close();
                            } else {
                              model.editActivity(
                                newActivity: Activity(
                                  textController.text,
                                  model.selectedColor.toHex(),
                                  model.selectedHabit,
                                  model.selectedDays,
                                  goal.isNegative ? model.selectedGoal : goal.inSeconds
                                ),
                                oldActivity: model.getActivityByName(model.selectedActivity, model.editSpecific).name,
                                specific: model.editSpecific
                              );
                              editActivityFromCalendar(textController.text, model.selectedActivity);
                              panelController.close();
                            }
                          } : () {}
                          )
                      ]
                    )
                  ]
                ),
              ],
            )
          ),
          maxPoint: () {
            if (model.selectedHabit) return 1.0;
            return 0.65;
        },
        );
      },
      child: widget.body
    );
  }
}

/// This class represents the complete color picker made of three rows

class ColorPickerWidget extends StatelessWidget {

  const ColorPickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: height / 30, top: height / 45),
      child: Column(
        children: [
          ColorsRowWidget(0),
          SizedBox(height: height / 49),
          ColorsRowWidget(1),
          SizedBox(height: height / 49),
          ColorsRowWidget(2)
        ]
      )
    );
  }
}

/// This class represents a row containing eight different colors

class ColorsRowWidget extends StatelessWidget {

  /// The index of the color in the row
  final int index;

  const ColorsRowWidget(this.index);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...List.generate(7, (i) {
          final color = colors[index]!.elementAt(i);
          return Consumer<ActivitiesModel>(
            builder: (context, model, child) {
              return GestureDetector(
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 10,
                  child: Icon(
                    Icons.check,
                    size: color == model.selectedColor ? 20 : 0,
                  )
                ),
                onTap: () {
                  if (color == model.selectedColor) {
                    return;
                  }
                  model.selectedColor = color!;
                  }
              );
            }
          );
        })
      ]
    );
  }
}

/// These are the possible colors for activities divided in three rows

final colors = {
  0: [
    Colors.red[400],
    Colors.green[400],
    Colors.orange[400],
    Colors.blue[400],
    Colors.purple[400],
    Colors.yellow[400],
    Colors.pink[400]
  ],
  1: [
    Colors.greenAccent[400],
    Colors.lightBlue[400],
    Colors.redAccent[400],
    Colors.yellowAccent[400],
    Colors.deepPurpleAccent[400],
    Colors.grey[400],
    Colors.orangeAccent[400]
  ],
  2: [
    Colors.pinkAccent[400],
    Colors.teal[400],
    Colors.blueAccent[400],
    Colors.lightBlueAccent[400],
    Colors.brown[400],
    Colors.purpleAccent[400],
    Colors.blueGrey[400]
  ]
};

/// This class represents the selector of the habit's days

class DaysSelectorWidget extends StatelessWidget {

  const DaysSelectorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.9,
      height: height / 24.4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(height / 73)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DayChoice("M"),
          DayChoice("T"),
          DayChoice("W"),
          DayChoice("R"),
          DayChoice("F"),
          DayChoice("S"),
          DayChoice("U")
        ]
      )
    );
  }
}

/// This class represents a single day inside the day selector

class DayChoice extends StatelessWidget {

  /// The day abbreviation
  final String day;

  const DayChoice(this.day);

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesModel>(
      builder: (context, model, child) {
        return Row(
          children: [
            GestureDetector(
              child: Container(
                width: width / 9,
                height: height / 36.6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(model.selectedDays.contains(day) ? 0.75 : 0),
                  borderRadius: BorderRadius.circular(height / 25)
                ),
                child: Center(
                  child: Text(
                    day
                  )
                )
              ),
              onTap: () {
                /// Remove day
                if (model.selectedDays.split("").contains(day)) {
                  String newDays = "";
                  for(String split in model.selectedDays.split("")) {
                    if (split != day) newDays += split;
                  }
                  model.selectedDays = newDays;
                  /// Add day
                } else {
                  model.selectedDays += day;
                }
              }
            ),
            if (day != "U") SizedBox(width: width / 78)
          ]
        );
      }
    );
  }
}