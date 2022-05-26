import 'package:flutter/material.dart';
import 'package:focus/pages/calendar/calendar_page_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';

class CalendarPage extends StatefulWidget {

  CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

var months = (BuildContext context) => [
  AppLocalizations.of(context)!.jan,
  AppLocalizations.of(context)!.feb,
  AppLocalizations.of(context)!.mar,
  AppLocalizations.of(context)!.apr,
  AppLocalizations.of(context)!.may,
  AppLocalizations.of(context)!.jun,
  AppLocalizations.of(context)!.jul,
  AppLocalizations.of(context)!.aug,
  AppLocalizations.of(context)!.sep,
  AppLocalizations.of(context)!.oct,
  AppLocalizations.of(context)!.nov,
  AppLocalizations.of(context)!.dec
];

class _CalendarPageState extends State<CalendarPage> {

  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(80, 163, 135, 1.0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height / 5),
        child: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(80, 163, 135, 1.0),
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(top: height / 50),
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
              padding: EdgeInsets.only(top: height / 50),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: months(context)[_selected.month - 1],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 52.3,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500
                  ),
                  children: [
                    TextSpan(
                      text: "\n${_selected.year}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: height / 81,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w400
                      )
                    )
                  ]
                )
              ),
            ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(height / 7),
            child: Container(
              color: Color.fromRGBO(80, 163, 135, 1.0),
              child: Padding(
                padding: EdgeInsets.only(bottom: height / 73),
                child: TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _selected,
                  currentDay: _selected,
                  calendarFormat: CalendarFormat.week,
                  headerVisible: false,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (date1, date2) {
                    setState(() {
                      _selected = date1;
                    });
                  },
                  onPageChanged: (date) {
                    setState(() {
                      _selected = date;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: height / 54,
                    ),
                    todayDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: height / 54,
                      color: Colors.white,
                      fontWeight: FontWeight.w600
                    ),
                    weekendTextStyle: TextStyle(
                        fontSize: height / 54,
                        color: Colors.white,
                        fontWeight: FontWeight.w600
                    ),
                    rangeStartTextStyle: TextStyle(
                        fontSize: height / 54,
                        color: Colors.white,
                        fontWeight: FontWeight.w600
                    ),
                    outsideTextStyle: TextStyle(
                        fontSize: height / 54,
                        color: Colors.white,
                        fontWeight: FontWeight.w600
                    ),
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor
                    )
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: height / 54,
                    ),
                      weekendStyle: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        fontSize: height / 54,
                      )
                  ),
                ),
              )
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(height / 21), topRight: Radius.circular(height / 21))
        ),
        child: Builder(
          builder: (context) {
            List<HabitTrackerItem> _hab = habits(context, _selected);
            List<Widget> _timeline = timelineElements(context, _selected);
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(height: height / 29),
                if (_hab.length != 0) HabitTracker(habits: _hab,),
                if (_timeline.length != 0) TimelineWidgets(timelineElements: _timeline),
                if (_hab.length == 0 && _timeline.length == 0) Container(
                  height: height / 1.55,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: height / 4.9,
                          color: Colors.black38,
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "No events today",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height / 45,
                            color: Colors.black38
                          )
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height / 29,)
              ],
            );
          }
        ),
      ),
    );
  }
}
