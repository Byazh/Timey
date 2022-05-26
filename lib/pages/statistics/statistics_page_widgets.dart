
import 'package:flutter/material.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:provider/provider.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';
import 'package:focus/activities/activities.dart';
import 'package:focus/models/models.dart';
import 'package:focus/pages/calendar/calendar_page.dart';
import 'package:focus/stats/stats.dart';
import 'package:focus/utils/color_utils.dart';

/// This class represents the segmented control used to select the period of time

class StatTimeSelector extends StatefulWidget {


  const StatTimeSelector({Key? key}) : super(key: key);

  @override
  _StatTimeSelectorState createState() => _StatTimeSelectorState();
}

/// This class represents the state of the above widget

class _StatTimeSelectorState extends State<StatTimeSelector> {

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsModel>(
      builder: (context, model, child) {
        return Container(
          child: MaterialSegmentedControl(
              onSegmentChosen: (String value) {
                if (model.period != value) model.period = value;
                model.selected = DateTime.now();
              },
              selectionIndex: model.period,
              selectedColor: Theme.of(context).primaryColor,
              borderColor: Colors.transparent,
              unselectedColor: Color.fromRGBO(64, 133, 110, 1),
              verticalOffset: height / 73,
              horizontalPadding: EdgeInsets.symmetric(vertical: height / 50.2, horizontal: width / 10),
              children: {
                "Day": Text(
                  "   ${AppLocalizations.of(context)!.day}   ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 61
                  ),
                ),
                "Week": Text(
                  "  ${AppLocalizations.of(context)!.week}  ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 61
                  ),
                ),
                "Month": Text(
                  "  ${AppLocalizations.of(context)!.month}  ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 61
                  ),
                ),
                "Year": Text(
                  "  ${AppLocalizations.of(context)!.year}  ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 61
                  ),
                ),
              }
          ),
        );
      },
    );
  }
}

/// This class represents the precise date selected

class DateWidget extends StatelessWidget {

  const DateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsModel>(
      builder: (context, model, child) {
        return Padding(
          padding: EdgeInsets.only(top: height / 350),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    var selected = model.selected;
                    switch (model.period) {
                      case "Day":
                        model.selected = selected.subtract(Duration(days: 1));
                        break;
                      case "Week":
                        model.selected = selected.subtract(Duration(days: 7));
                        break;
                      case "Month":
                        model.selected = selected.month != 1 ? DateTime(selected.year, selected.month - 1) : DateTime(selected.year - 1, 12);
                        break;
                      case "Year":
                        model.selected = DateTime(selected.year - 1);
                        break;
                    }
                  }
              ),
              Text(
                getText(model, context),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: height / 58
                ),
              ),
              IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    var selected = model.selected;
                    switch (model.period) {
                      case "Day":
                        model.selected = selected.add(Duration(days: 1));
                        break;
                      case "Week":
                        model.selected = selected.add(Duration(days: 7));
                        break;
                      case "Month":
                        model.selected = selected.month != 12 ? DateTime(selected.year, selected.month + 1) : DateTime(selected.year + 1, 1);
                        break;
                      case "Year":
                        model.selected = DateTime(selected.year + 1);
                        break;
                    }
                  }
              ),
            ],
          ),
        );
      }
    );
  }
}

String getText(StatisticsModel model, BuildContext context) {
  String text = "";
  DateTime time = model.selected;
  switch (model.period) {
    case "Day":
      text = "${time.day} ${months(context)[time.month - 1].substring(0, 3)}, ${time.year}";
      break;
    case "Week":
      DateTime start = time.subtract(Duration(days: time.weekday - 1));
      DateTime end = time.add(Duration(days: 7 - time.weekday));
      text = "${start.day} ${months(context)[start.month - 1].substring(0, 3)} - ${end.day} ${months(context)[end.month - 1].substring(0, 3)}, ${end.year}";
      break;
    case "Month":
      text = "${months(context)[time.month - 1].substring(0, 3)}, ${time.year}";
      break;
    case "Year":
      text = "${time.year}";
      break;
  }
  return text;
}

/// This class represents the container of the statistics

class StatContainer extends StatelessWidget {

  final Widget child;
  final double heightFactor;

  const StatContainer(this.child, [this.heightFactor = 1.89]);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height * heightFactor,
      margin: EdgeInsets.only(top: height / 29.5),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 250, 192, 1.0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(35))
      ),
      child: child,
    );
  }
}

/// This class represents the graph that displays the focus time distribution

class TimeDistributionGraph extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            SizedBox(height: height / 30),
            TitleMenuText(
              title: AppLocalizations.of(context)!.focusTimeDistribution,
              alignment: Alignment.center,
              color: Color.fromRGBO(64, 133, 110, 1),
            ),
            TitleMenuText(
              title: totalFocusText(model.period, model.selected, context),
              alignment: Alignment.center,
              color: Color.fromRGBO(72, 153, 127, 0.5),
              size: height / 66.5,
            ),
            SizedBox(height: height / 30),
            Container(
                margin: EdgeInsets.symmetric(horizontal: width / 12),
                height: height / 3,
                child: charts.BarChart(
                  createSampleData(model, context),
                  animate: true,
                  animationDuration: Duration(milliseconds: 500),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                      tickProviderSpec:
                      new charts.BasicNumericTickProviderSpec(desiredTickCount: 4),
                    showAxisLine: false,
                    renderSpec: charts.SmallTickRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        fontSize: (height / 65).round()
                      ),
                      axisLineStyle: charts.LineStyleSpec(
                        thickness: 0,
                      )
                    )

                  ),
                  domainAxis: charts.OrdinalAxisSpec(
                    tickProviderSpec: spec(model),
                    showAxisLine: false,
                    renderSpec: charts.SmallTickRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        fontSize: (height / 65).round()
                      ),
                        axisLineStyle: charts.LineStyleSpec(
                          thickness: 0,
                        )
                    )
                  ),
                )
            ),
          ],
        );
      }
    );
  }

  charts.OrdinalTickProviderSpec spec(StatisticsModel model) {
    charts.OrdinalTickProviderSpec spec = charts.BasicOrdinalTickProviderSpec();
    switch (model.period) {
      case "Day":
        spec = charts.StaticOrdinalTickProviderSpec(
            [
              charts.TickSpec("0", label: "00"),
              charts.TickSpec("4", label: "04"),
              charts.TickSpec("8", label: "08"),
              charts.TickSpec("12", label: "12"),
              charts.TickSpec("16", label: "16"),
              charts.TickSpec("20", label: "20"),
              charts.TickSpec("23", label: "23")
            ]
        );
        break;
      case "Week":
        spec = charts.BasicOrdinalTickProviderSpec();
        break;
      case "Month":
        spec = charts.StaticOrdinalTickProviderSpec(
            [
              charts.TickSpec("1", label: "1"),
              charts.TickSpec("6", label: "6"),
              charts.TickSpec("12", label: "12"),
              charts.TickSpec("18", label: "18"),
              charts.TickSpec("24", label: "24"),
              charts.TickSpec("30", label: "30")
            ]
        );
        break;
      case "Year":
        spec = charts.BasicOrdinalTickProviderSpec();
        break;
    }
    return spec;
  }

  static List<charts.Series<Statistic, String>> createSampleData(StatisticsModel model, BuildContext context) {
    List<Statistic>? data;
    switch (model.period) {
      case "Day":
        data = dailyData(model.selected);
        break;
      case "Week":
        data = weeklyData(model.selected);
        break;
      case "Month":
        data = monthlyData(model.selected);
        break;
      case "Year":
        data = yearlyData(model.selected);
        break;
    }
    double maxFocus = 0;
    if (data != null) {
      var temp = List.from(data);
      temp.sort((a, b) => b.number!.compareTo(a.number as num));
      maxFocus = temp.first.number;
    }
    return [
      new charts.Series<Statistic, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color.fromRGBO(80, 163, 135, 1.0)),
        domainFn: (Statistic sales, _) => model.period == "Year" ? months(context)[int.parse(sales.time) - 1].substring(0, 2) : sales.time,
        measureFn: (Statistic sales, _) => number(sales.number, maxFocus),
        data: data == null ? [] : data
      )
    ];
  }

  static double? number(double? number, double maxFocus) {
    if (maxFocus == 0) {
      return 0.1;
    }
    if (number == 0) {
      return maxFocus / 35;
    }
    return number;
  }
}

class Statistic {

  final String time;
  final double? number;
  final Color color;

  Statistic(this.time, this.number, [this.color = Colors.red]);
}

ValueNotifier pieStat = ValueNotifier("Overall");

/// This class represents the graph that displays the activities time distribution

class ActivitiesGraph extends StatelessWidget {

  const ActivitiesGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivitiesModel provider = Provider.of<ActivitiesModel>(context, listen: false);
    List<Activity> general = provider.activities["general"];
    return ValueListenableBuilder(
      valueListenable: pieStat,
      builder: (BuildContext context, value, Widget? child) {
        return Consumer<StatisticsModel>(
            builder: (context, model, child) {
              return Column(
                children: [
                  SizedBox(height: height / 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          TitleMenuText(
                            title: value == "Overall"
                                ? AppLocalizations.of(context)!.activitiesDistribution
                                : "${value} ${AppLocalizations.of(context)!.distribution}",
                            alignment: Alignment.center,
                            color: Color.fromRGBO(64, 133, 110, 1),
                          ),
                          TitleMenuText(
                            title: totalTimeActivity(model, context),
                            alignment: Alignment.center,
                            color: Color.fromRGBO(72, 153, 127, 0.5333333333333333),
                            size: height / 66.5,
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      /*
                      PopupMenuButton<String>(
                        elevation: 2,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)
                        ),
                        child: Icon(
                            Icons.expand_more_outlined,
                            color: Color.fromRGBO(64, 133, 110, 1)
                        ),
                        itemBuilder: (context) => List.generate(
                            general.length + 1,
                                (index) {
                              if (index == 0) {
                                return PopupMenuItem<String>(
                                  value: "Overall",
                                  child: ListTile(
                                    leading: CircleAvatar(
                                        backgroundColor: Colors.pink,
                                        radius: height / 73
                                    ),
                                    title: Text(
                                      "Overall",
                                      style: TextStyle(
                                          fontSize: height / 45
                                      ),
                                    ),
                                  ),
                                );
                              }
                              Activity activity = general[index - 1];
                              return PopupMenuItem<String>(
                                value: activity.name,
                                child: Container
                                  margin: EdgeInsets.only(top: height / 100),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                        backgroundColor: HexColor.fromHex(activity.color),
                                        radius: height / 73
                                    ),
                                    title: Text(
                                      activity.name,
                                      style: TextStyle(
                                          fontSize: height / 45
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                        onSelected: (activity) {
                          pieStat.value = activity;
                        },
                      )
                       */
                    ],
                  ),
                  SizedBox(height: height / 30,),
                  Container(
                      height: height / 3,
                      width: width * 0.8,
                      child: charts.PieChart<Object>(
                        _createSampleData(context, model),
                        animate: true,
                        animationDuration: Duration(milliseconds: 500),
                        defaultRenderer: charts.ArcRendererConfig(
                            arcWidth: (height / 12).round(),
                            arcRendererDecorators: [
                              charts.ArcLabelDecorator(
                                  labelPosition: charts.ArcLabelPosition.auto
                              )
                            ]
                        )
                      )
                  )
                ]
              );
            }
        );
      },
    );
  }

  String totalTimeActivity(StatisticsModel model, BuildContext context) {
    String selectedStat = pieStat.value;
    if (selectedStat == "Overall") {
      return AppLocalizations.of(context)!.clickHereToSelectActivity;
    }
    DateTime date = model.selected;
    try {
      switch (model.period) {
        case "Day":
          final minutes = Duration(minutes: activitiesJson[selectedStat][date.year.toString()][date.month.toString()][date.day]);
          return "${AppLocalizations.of(context)!.totalFocusTime}${minutes.inHours}h and ${minutes.inMinutes - minutes.inHours * 60}m";
        case "Week":
          var minutes = 0;
          DateTime monday = date.subtract(Duration(days: date.weekday - 1));
          for (int i = 0; i < 7; i++) {
            DateTime current = monday.add(Duration(days: i));
            minutes += activitiesJson[selectedStat][current.year.toString()][current.month.toString()][current.day] as int;
          }
          final duration = Duration(minutes: minutes);
          return "${AppLocalizations.of(context)!.totalFocusTime}${duration.inHours}h and ${duration.inMinutes - duration.inHours * 60}m";
        case "Month":
          final minutes = Duration(minutes: activitiesJson[selectedStat][date.year.toString()][date.month.toString()][0]);
          return "${AppLocalizations.of(context)!.totalFocusTime}${minutes.inHours}h and ${minutes.inMinutes - minutes.inHours * 60}m";
        case "Year":
          final minutes = Duration(minutes: activitiesJson[selectedStat][date.year.toString()]["minutes"]);
          return "${AppLocalizations.of(context)!.totalFocusTime}${minutes.inHours}h and ${minutes.inMinutes - minutes.inHours * 60}m";
      }
    } on Error {
      return "${AppLocalizations.of(context)!.totalFocusTime}0h and 0m";
    }
    return AppLocalizations.of(context)!.clickHereToSelectActivity;
  }

  static List<charts.Series<Statistic, String>> _createSampleData(BuildContext context, StatisticsModel model) {
    List<Statistic>? data;
    ActivitiesModel provider = Provider.of<ActivitiesModel>(context, listen: false);
    switch (model.period) {
      case "Day":
        data = dailyActivities(model.selected, pieStat.value, provider);
        break;
      case "Week":
        data = weeklyActivities(model.selected, pieStat.value, provider);
        break;
      case "Month":
        data = monthlyActivities(model.selected, pieStat.value, provider);
        break;
      case "Year":
        data = yearlyActivities(model.selected, pieStat.value, provider);
        break;
    }
    if (data != null && pieStat.value == "Overall") data.removeWhere((element) => Provider.of<ActivitiesModel>(context).isActivitySpecific(element.time));
    return [
      new charts.Series<Statistic, String>(
          id: 'Sales',
          colorFn: (sales, __) {
            return sales.time == "Blank" ? charts.ColorUtil.fromDartColor(Color.fromRGBO(80, 163, 135, 1)) : charts.ColorUtil.fromDartColor(HexColor.fromHex(Provider.of<ActivitiesModel>(context, listen: false).getActivityByName(sales.time, pieStat.value == "Overall" ? false : true).color));
          },
          domainFn: (Statistic sales, _) => sales.time,
          measureFn: (Statistic sales, _) => sales.number,
          data: data == null
               ? [Statistic("Blank", 100.0)]
              : data.where((element) => element.number != 0).length == 0 ?[
          Statistic("Blank", 100.0)] : data,
          labelAccessorFn: (sales, _) {
            return sales.time == "Blank" ? "No data" : "${minutesToHours(sales.number!.toInt()).replaceAll(" and ", " ")}";
          }
      )
    ];
  }
}

/// This class represents the list of activities in the graph

class ActivitiesLegendWidget extends StatelessWidget {

  const ActivitiesLegendWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivitiesModel provider = Provider.of<ActivitiesModel>(context, listen: false);
    return ValueListenableBuilder(
      valueListenable: pieStat,
      builder: (context, value, child) {
        return Container(
          height: height / 30,
          margin: EdgeInsets.symmetric(horizontal: width / 10),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Theme.of(context).scaffoldBackgroundColor, Colors.transparent, Colors.transparent, Theme.of(context).scaffoldBackgroundColor],
                stops: [0.0, 0.2, 0.8, 1],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstOut,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: value == "Overall" ? provider.activities["general"].length : provider.activities["specific"][pieStat.value].length,
              itemBuilder: (context, index) {
                Activity? activity;
                if (value == "Overall") {
                  activity = provider.activities["general"][index];
                } else {
                  activity = provider.activities["specific"][value][index];
                }
                return ActivitiesLegendItem(name: activity!.name, color: HexColor.fromHex(activity.color));
              },
            ),
          ),
        );
      }
    );
  }
}

class ActivitiesLegendItem extends StatelessWidget {

  final String name;
  final Color color;

  const ActivitiesLegendItem({Key? key, required this.name, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: width / 27),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: height / 122,
          ),
          Text(
            "  $name",
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: Color.fromRGBO(64, 133, 110, 1),
              fontSize: height / 56
            ),
          )
        ]
      )
    );
  }
}

/// This class represents the graph that displays the failure reasons

class FailureReasonsChart extends StatelessWidget {

  late List<charts.Series<Statistic, String>> seriesList;

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsModel>(
      builder: (contextt, model, child) {
        seriesList = createSampleData(contextt, model);
        return Column(
          children: [
            SizedBox(height: height / 20,),
            TitleMenuText(
              title: AppLocalizations.of(context)!.failureReasonDistribution,
              alignment: Alignment.center,
              color: Color.fromRGBO(64, 133, 110, 1),
            ),
            TitleMenuText(
              title: AppLocalizations.of(context)!.toUnderstandWhy,
              alignment: Alignment.center,
              color: Color.fromRGBO(72, 153, 127, 0.5333333333333333),
              size: height / 66.5,
            ),
            SizedBox(height: height / 50,),
            Container(
                margin: EdgeInsets.symmetric(horizontal: width / 12),
                height: height / 3,
                child: charts.BarChart(
                  seriesList,
                  animate: true,
                  vertical: false,
                  animationDuration: Duration(milliseconds: 500),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                    tickProviderSpec:
                    new charts.BasicNumericTickProviderSpec(desiredMinTickCount: 4),
                      showAxisLine: true,
                      renderSpec: charts.SmallTickRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                              fontSize: (height / 65).round()
                          ),
                          axisLineStyle: charts.LineStyleSpec(
                            thickness: 0,
                          )
                      )
                  ),
                  domainAxis: charts.OrdinalAxisSpec(
                      showAxisLine: false,
                      renderSpec: charts.SmallTickRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                              fontSize: (height / 65).round()
                          ),
                          axisLineStyle: charts.LineStyleSpec(
                            thickness: 0,
                          )
                      )
                  ),
                )
            ),
          ],
        );
      },
    );
  }

  static List<charts.Series<Statistic, String>> createSampleData(BuildContext context, StatisticsModel model) {
    final names = [
      AppLocalizations.of(context)!.reason1,
      AppLocalizations.of(context)!.reason2,
      AppLocalizations.of(context)!.reason3,
      AppLocalizations.of(context)!.reason4,
      AppLocalizations.of(context)!.reason5,
      AppLocalizations.of(context)!.reason6
    ];
    final data = <Statistic>[];
    final date = model.selected;
    for (int i = 0; i < 6; i++) {
      switch (model.period) {
        case "Day":
          data.add(Statistic(names[i], timeJson["${date.year}"]["${date.month}"]["${date.day}"][24 + i].toDouble()));
          break;
        case "Week":
          double number = 0;
          DateTime monday = date.subtract(Duration(days: date.weekday - 1));
          for (int day = 0; day < 7; day++) {
            DateTime current = monday.add(Duration(days: day));
            try {
              number += timeJson["${current.year}"]["${current.month}"]["${current.day}"][24 + i];
            } on Error {}
          }
          data.add(Statistic(names[i], number));
          break;
        case "Month":
          data.add(Statistic(names[i], timeJson["${date.year}"]["${date.month}"]["reasons"][i].toDouble()));
          break;
        case "Year":
          data.add(Statistic(names[i], timeJson["${date.year}"]["reasons"][i].toDouble()));
          break;
      }
    }
    return [
      new charts.Series<Statistic, String>(
          id: 'Sales',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color.fromRGBO(80, 163, 135, 1.0)),
          domainFn: (Statistic sales, _) => sales.time,
          measureFn: (Statistic sales, _) => sales.number,
          data: data
      )
    ];
  }
}

/// This class represents the graph that displays the most focused period of the day or week

class MostFocusedPeriodGraph extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            SizedBox(height: height / 30,),
            TitleMenuText(
              title: AppLocalizations.of(context)!.mostFocusedPeriod,
              alignment: Alignment.center,
              color: Color.fromRGBO(64, 133, 110, 1),
            ),
            TitleMenuText(
              title: totalPeriodText(model.period, model.selected, context),
              alignment: Alignment.center,
              color: Color.fromRGBO(72, 153, 127, 0.53),
              size: height / 66.5,
            ),
            SizedBox(height: height / 50,),
            Container(
                margin: EdgeInsets.symmetric(horizontal: width / 12),
                height: height / 3,
                child: charts.LineChart(
                  createSampleData(model),
                  animate: true,
                  animationDuration: Duration(milliseconds: 500),
                  domainAxis: charts.NumericAxisSpec(
                    tickProviderSpec: spec(model),
                    showAxisLine: false,
                      renderSpec: charts.SmallTickRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                              fontSize: (height / 65).round()
                          ),
                          axisLineStyle: charts.LineStyleSpec(
                            thickness: 0,
                          )
                      )
                  ),
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    showAxisLine: false,
                      renderSpec: charts.SmallTickRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                              fontSize: (height / 65).round()
                          ),
                          axisLineStyle: charts.LineStyleSpec(
                            thickness: 0,
                          )
                      ),

                  ),
                )
            ),
          ],
        );
      }
    );
  }

  static List<charts.Series<Statistic, int>> createSampleData(StatisticsModel model) {
    var data;
    switch (model.period) {
      case "Day":
        data = dailyData(model.selected);
        break;
      case "Week":
        data = weeklyPeriodData(model.selected);
        break;
      case "Month":
        data = monthlyPeriodData(model.selected);
        break;
      case "Year":
        data = yearlyPeriodData(model.selected);
        break;
    }
    return [
      new charts.Series<Statistic, int>(
          id: 'Sales',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color.fromRGBO(80, 163, 135, 1.0)),
          domainFn: (Statistic sales, _) => int.parse(sales.time),
          measureFn: (Statistic sales, _) => sales.number,
          data: data == null ? [] : data
      )
    ];
  }

  charts.NumericTickProviderSpec spec(StatisticsModel model) {
    charts.NumericTickProviderSpec spec = charts.StaticNumericTickProviderSpec([]);
    switch (model.period) {
      case "Day":
        spec = charts.StaticNumericTickProviderSpec(
            [
              charts.TickSpec(0, label: "00"),
              charts.TickSpec(4, label: "04"),
              charts.TickSpec(8, label: "08"),
              charts.TickSpec(12, label: "12"),
              charts.TickSpec(16, label: "16"),
              charts.TickSpec(20, label: "20"),
              charts.TickSpec(23, label: "23")
            ]
        );
        break;
      case "Week":
        spec = charts.StaticNumericTickProviderSpec(
            [
              charts.TickSpec(0, label: "00"),
              charts.TickSpec(4, label: "04"),
              charts.TickSpec(8, label: "08"),
              charts.TickSpec(12, label: "12"),
              charts.TickSpec(16, label: "16"),
              charts.TickSpec(20, label: "20"),
              charts.TickSpec(23, label: "23")
            ]
        );
        break;
      case "Month":
        spec = charts.StaticNumericTickProviderSpec(
            [
              charts.TickSpec(0, label: "M"),
              charts.TickSpec(1, label: "T"),
              charts.TickSpec(2, label: "W"),
              charts.TickSpec(3, label: "R"),
              charts.TickSpec(4, label: "F"),
              charts.TickSpec(5, label: "S"),
              charts.TickSpec(6, label: "U")
            ]
        );
        break;
      case "Year":
        spec = charts.StaticNumericTickProviderSpec(
            [
              charts.TickSpec(1, label: "Ja"),
              charts.TickSpec(2, label: "Fe"),
              charts.TickSpec(3, label: "Ma"),
              charts.TickSpec(4, label: "Ap"),
              charts.TickSpec(5, label: "Ma"),
              charts.TickSpec(6, label: "Ju"),
              charts.TickSpec(7, label: "Jl"),
              charts.TickSpec(8, label: "Au"),
              charts.TickSpec(9, label: "Se"),
              charts.TickSpec(10, label: "Oc"),
              charts.TickSpec(11, label: "No"),
              charts.TickSpec(12, label: "De")
            ]
        );
        break;
    }
    return spec;
  }
}