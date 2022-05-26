import 'package:flutter/material.dart';
import 'package:focus/activities/activities.dart';
import 'package:focus/main.dart';
import 'package:focus/models/models.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/stats/stats.dart';
import 'package:focus/timeline/timeline.dart';
import 'package:focus/utils/color_utils.dart';
import 'package:focus/utils/date_utils.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HabitTracker extends StatelessWidget {

  final List<HabitTrackerItem> habits;

  const HabitTracker({Key? key, required this.habits}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(left: width / 19, right: width / 19),
            child: TitleMenuText(
              title: AppLocalizations.of(context)!.habitTracker,
              color: Color.fromRGBO(44, 106, 85, 1.0),
              size: height / 52
            )
        ),
        SizedBox(height: height / 29,),
        ...habits
      ],
    );
  }
}

final daysOfWeek = ["M", "T", "W", "R", "F", "S", "U"];

List<HabitTrackerItem> habits(BuildContext context, DateTime date) {
  List<HabitTrackerItem> habits = [];
  ActivitiesModel model = Provider.of<ActivitiesModel>(context, listen: false);
  model.activities["general"].forEach((Activity general) {
    if (general.habit == true) {
      if (general.days.contains(daysOfWeek[date.weekday - 1])) {
        habits.add(HabitTrackerItem(activity: general, date: date,));
      }
    }
    /*
    model.activities["specific"][general.name].forEach((Activity specific) {
      if (specific.habit == true) {
        if (general.days.contains(daysOfWeek[date.weekday - 1]))
        habits.add(HabitTrackerItem(activity: specific, date: date,));
      }
    });
     */
  });
  return habits;
}

class Argument {

  final Activity activity;
  final DateTime date;

  Argument(this.activity, this.date);
}

class HabitTrackerItem extends StatefulWidget {

  final Activity activity;
  final DateTime date;

  const HabitTrackerItem({Key? key, required this.activity, required this.date}) : super(key: key);

  @override
  _HabitTrackerItemState createState() => _HabitTrackerItemState();
}

class _HabitTrackerItemState extends State<HabitTrackerItem> {

  double _value = 0;

  @override
  Widget build(BuildContext context) {
    Activity activity = widget.activity;
    DateTime date = widget.date;
    try {
      _value = activitiesJson[activity.name][date.year.toString()][date.month.toString()][date.day].toDouble();
      if (_value >= activity.goal / 60) {
        _value = activity.goal / 60;
      }
    } on Error {
      _value = 0;
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HabitDetailsPage(argument: Argument(activity, date),)),
        );
      },
      child: Container(
        width: width * 0.8,
        height: height / 9.5,
        margin: EdgeInsets.only(bottom: height / 29),
        decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 225, 1.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 10
              )
            ],
            borderRadius: BorderRadius.circular(height / 49)
        ),
        child: Padding(
          padding: EdgeInsets.only(left: width / 15.6, right: width / 15.6, top: height / 73),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.activity.name,
                    style: TextStyle(
                        color: HexColor.fromHex(widget.activity.color),
                        fontSize: height / 48,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    "${_value.toStringAsFixed(0)}m / ${(widget.activity.goal / 60).toStringAsFixed(0)}m",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      fontSize: height / 61
                    ),
                  )
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                    thumbColor: Colors.transparent,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: height / 146)
                ),
                child: Slider(
                    onChanged: (double value) {},
                    value: _value,
                    activeColor: HexColor.fromHex(widget.activity.color),
                    inactiveColor: Colors.grey.withOpacity(0.3),
                    min: 0,
                    max: widget.activity.goal == 0 ? 10 : widget.activity.goal / 60
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TimelineWidgets extends StatelessWidget {

  final List<Widget> timelineElements;

  const TimelineWidgets({Key? key, required this.timelineElements}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(left: width / 19, right: width / 19, bottom: height / 29),
            child: TitleMenuText(
              title: AppLocalizations.of(context)!.timeline,
              color: Color.fromRGBO(44, 106, 85, 1.0),
              size: height / 52,
            )
        ),
        ...timelineElements
      ],
    );
  }
}

List<Widget> timelineElements(BuildContext context, DateTime date) {
  List<Widget> elements = [];
  var a = timeline["timeline"][formatDate(date)];
  try {
    a.forEach((element) {
      elements.add(SingleTimelineElement(
        start: element["start"],
        end: element["end"],
        plant: element["plant"],
        activity: Provider.of<ActivitiesModel>(context, listen: false).activities["general"][element["activity"]].name,
        successful: element["successful"],
        text: element["text"],
      ));
      if (a.indexOf(element) != a.length - 1) elements.add(Container(
        width: 5,
        height: 35,
        color: Colors.grey.withOpacity(0.5),
      ));
    });
  } on Error {}
  if (elements.length.isEven && elements.length != 0) elements.removeLast();
  return elements;
}

class SingleTimelineElement extends StatelessWidget {

  final String start, end;
  final String activity;
  final bool successful;
  final String text;
  final String plant;

  const SingleTimelineElement({Key? key, required this.start, required this.end, required this.activity, required this.successful, required this.text, required this.plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        methodInfo(context, "${AppLocalizations.of(context)!.thisSessionNotes}\n", text, true);
      },
      child: Container(
          width: width * 0.8,
          height: height / 5.3,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 20),
              color: Color.fromRGBO(255, 255, 225, 1.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: height / 91),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.label,
                          color: Colors.black45,
                          size: height / 52,
                        ),
                        Text(
                          "  $activity",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: height / 58.6,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "$start",
                    style: TextStyle(
                        color: Color.fromRGBO(101, 101, 101, 1),
                        fontSize: height / 48.8,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  Image.asset(
                    "resources/images/${plantNames.indexOf(plant) == -1 ? "logo" : "plants/${plantNames.indexOf(plant)}"}.png",
                    height: height / 14.6,
                  ),
                  Text(
                    "$end",
                    style: TextStyle(
                        color: Color.fromRGBO(101, 101, 101, 1),
                        fontSize: height / 48.8,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
              Container(
                height: height / 20,
                width: width * 0.8,
                margin: EdgeInsets.only(top: height / 183),
                decoration: BoxDecoration(
                    color: successful? Color.fromRGBO(101, 199, 89, 1.0) : Colors.redAccent,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(height  / 20), bottomRight: Radius.circular(height / 20))
                ),
                child: Center(
                  child: Text(
                    successful ? AppLocalizations.of(context)!.success : AppLocalizations.of(context)!.failed,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 56
                    ),
                  ),
                )
              )
            ],
          )
      ),
    );
  }
}

class HabitDetailsPage extends StatefulWidget {

  final Argument argument;

  HabitDetailsPage({Key? key, required this.argument}) : super(key: key);

  @override
  _HabitDetailsPageState createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {

  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _selected = DateTime(1943, 8, 2);

  @override
  Widget build(BuildContext context) {
    final args = widget.argument;
    if (_selected == DateTime(1943, 8, 2)) _selected = DateTime.now();
    final newArg = Argument(args.activity, _selected);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height / 11.5),
        child: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).backgroundColor,
          leading: Padding(
            padding: EdgeInsets.only(top: height / 60),
            child: GestureDetector(
                child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: height / 35
                ),
                onTap: () {
                  Navigator.pop(context);
                }
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: height / 60),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "${args.activity.name}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: height / 52.3,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900
                    ),
                    children: [
                      TextSpan(
                          text: "\n${AppLocalizations.of(context)!.habitTracker}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: height / 75,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w400
                          )
                      )
                    ]
                )
            ),
          ),
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            margin: EdgeInsets.all(height / 30),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 225, 1.0),
                borderRadius: BorderRadius.circular(height / 24.5),
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 0.15,
                      blurRadius: 15,
                      color: Colors.black12
                  )
                ]
            ),
            child: Container(
              margin: EdgeInsets.all(height / 50),
              child: TableCalendar(
                locale: locale.value.languageCode,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                startingDayOfWeek: StartingDayOfWeek.monday,
                focusedDay: _selected,
                calendarFormat: _calendarFormat,
                formatAnimationDuration: Duration(seconds: 1),
                formatAnimationCurve: Curves.linearToEaseOut,
                onPageChanged: (date) {
                  setState(() {
                    if (date.year == DateTime.now().year && date.month == DateTime.now().month) _selected = DateTime.now();
                    else if (date.isBefore(DateTime.now())) _selected = DateTime(date.year, date.month + 1).subtract(Duration(days: 1));
                    else _selected = date;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: height / 52
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date1, focused) {
                    final temp = args.activity.days;
                    final days = List.empty(growable: true);
                    temp.split("").forEach((element) {
                      days.add(daysOfWeek.indexOf(element) + 1);
                    });
                    try {
                      if (days.contains(date1.weekday)) {
                        if (timeline["habits"][args.activity.name].contains(formatDate(date1))) {
                          return CircleAvatar(
                            child: Text(
                              "${date1.day}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height / 56
                              ),
                            ),
                            radius: height / 45,
                            backgroundColor: Theme.of(context).primaryColor,
                          );
                        }
                        if (date1.isBefore(_selected) || (date1.isBefore(DateTime.now()) && date1.compareTo(_selected) == 0)) {
                          return CircleAvatar(
                            child: Text(
                              "${date1.day}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height / 56
                              ),
                            ),
                            radius: height / 45,
                            backgroundColor: Colors.red.withOpacity(0.7),
                          );
                        }
                        return CircleAvatar(
                          child: Text(
                            "${date1.day}",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: height / 56
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                        );
                      } else {
                        return CircleAvatar(
                          child: Text(
                            "${date1.day}",
                            style: TextStyle(
                                color: date1.isBefore(DateTime.now()) ? Colors.white : Colors.black54,
                                fontSize: height / 56
                            ),
                          ),
                          radius: height / 45,
                          backgroundColor: date1.isBefore(DateTime.now()) ? Colors.grey.withOpacity(0.6) : Colors.transparent,
                        );
                      }
                    } on Error {
                      return Text(
                          "${date1.day}",
                        style: TextStyle(
                          fontSize: height / 56
                        ),
                      );
                    }
                  },
                  todayBuilder: (context, date1, focus) {
                    final temp = args.activity.days;
                    final days = List.empty(growable: true);
                    temp.split("").forEach((element) {
                      days.add(daysOfWeek.indexOf(element) + 1);
                    });
                    if (date1.month != _selected.month) {
                      return CircleAvatar(
                        child: Text(
                          "${date1.day}",
                          style: TextStyle(
                              color: Colors.black12,
                              fontSize: height / 56
                          ),
                        ),
                          radius: height / 45,
                        backgroundColor: Colors.transparent
                      );
                    }
                    if (days.contains(date1.weekday)) {
                      return CircleAvatar(
                        child: Text(
                          "${date1.day}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: height / 56
                          ),
                        ),
                        radius: height / 45,
                        backgroundColor: timeline["habits"][args.activity.name].contains(formatDate(date1)) ? Theme.of(context).primaryColor : Colors.red.withOpacity(0.75),
                      );
                    } else {
                      return CircleAvatar(
                        child: Text(
                          "${date1.day}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: height / 56
                          ),
                        ),
                        radius: height / 45,
                        backgroundColor: Colors.grey.withOpacity(0.6),
                      );
                    }
                  },
                  outsideBuilder: (context, date1, focused) {
                    return CircleAvatar(
                      child: Text(
                        "${date1.day}",
                        style: TextStyle(
                            color: Colors.black12,
                            fontSize: height / 56
                        ),
                      ),
                      radius: height / 45,
                      backgroundColor: Colors.transparent,
                    );
                  }
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width / 13, vertical: height / 49),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HabitStat(
                  arg: newArg,
                    stat: "done",
                  icon: Icon(
                    Icons.done,
                    color: Colors.green,
                    size: height / 24.4,
                  ),
                ),
                HabitStat(
                  arg: newArg,
                  stat: "undone",
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: height / 24.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width / 13, vertical: height / 49),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HabitStat(
                  arg: newArg,
                  stat: "done ratio",
                  icon: Icon(
                    Icons.stacked_line_chart,
                    color: Colors.green,
                    size: height / 24.4,
                  ),
                ),
                HabitStat(
                  arg: newArg,
                  stat: "undone ratio",
                  icon: Icon(
                    Icons.show_chart,
                    color: Colors.red,
                    size: height / 24.4,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class HabitStat extends StatelessWidget {

  final Argument arg;
  final String stat;
  final Icon icon;

  const HabitStat({Key? key, required this.stat, required this.icon, required this.arg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String number = "0";
    int done = 0;
    int undone = arg.date.day;
    final temp = arg.activity.days;
    final days = List.empty(growable: true);
    temp.split("").forEach((element) {
      days.add(daysOfWeek.indexOf(element) + 1);
    });
    try {
      for (String string in timeline["habits"][arg.activity.name].toSet()) {
        final split = string.split("/");
        DateTime date = DateTime(int.parse(split[2]), int.parse(split[1]), int.parse(split[0]));
        if (date.month == arg.date.month && date.year == arg.date.year && days.contains(date.weekday)) {
          done += 1;
        }
      }
      for (int i = undone; i > 0; i--) {
        final date = DateTime(arg.date.year, arg.date.month, i);
        if (!days.contains(date.weekday)) {
          undone -= 1;
        }
      }
      undone -= done;
    } catch (e) {
      print(e);
    }
    switch (stat) {
      case "done":
        number = "$done";
        break;
      case "undone":
        number = "$undone";
        break;
      case "done ratio":
        if (undone == 0) number = "100.0%";
        else number = "${(done / undone * 100).toStringAsFixed(2)}%";
        break;
      case "undone ratio":
        if (done == 0) number = "100.0%";
        else number = "${(100 - (done / undone * 100)).toStringAsFixed(2)}%";
        break;
    }
    return Container(
      width: width / 2.6,
      height: height / 6,
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 225, 1.0),
        borderRadius: BorderRadius.circular(height / 24.5),
        boxShadow: [
          BoxShadow(
            spreadRadius: 0.15,
            blurRadius: 15,
            color: Colors.black12
          )
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(height: height / 50),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: number,
              style: TextStyle(
                color: Colors.black87,
                fontSize: height / 36.6,
                fontWeight: FontWeight.w700
              ),
              children: [
                TextSpan(
                  text: "\n${converter(stat, context)}",
                  style: TextStyle(
                    color: Colors.black54,
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
}

String converter(String stat, BuildContext context) {
  switch (stat) {
    case "done":
      return AppLocalizations.of(context)!.doneHabit;
    case "undone":
      return AppLocalizations.of(context)!.undone;
    case "done ratio":
      return AppLocalizations.of(context)!.doneRatio;
    case "undone ratio":
      return AppLocalizations.of(context)!.undoneRatio;
  }
  return stat;
}
