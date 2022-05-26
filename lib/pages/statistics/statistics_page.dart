import 'package:flutter/material.dart';

import '../../main.dart';
import 'package:focus/pages/statistics/statistics_page_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This class represents the statistics page of the application, which appears
/// if you click on the first item of the drawer

class StatisticsPage extends StatefulWidget {

  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

/// This class represents the state of the above widget

class _StatisticsPageState extends State<StatisticsPage> {

  /// The body of the page
  late Widget body;
  /// The controller of the list view
  final controller = ScrollController();
  /// The background color
  var color = Color.fromRGBO(80, 163, 135, 1.0);

  @override
  void initState() {
    body = ListView(
      controller: controller,
        physics: BouncingScrollPhysics(),
        children: [
          StatTimeSelector(),
          DateWidget(),
          StatContainer(
              Column(
                children: [
                  TimeDistributionGraph(),
                  MostFocusedPeriodGraph(),
                  ActivitiesGraph(),
                  SizedBox(height: height / 60,),
                  ActivitiesLegendWidget(),
                  FailureReasonsChart()
                ],
              )
          )
        ]
    );
    controller.addListener(_listener);
    super.initState();
  }

  /// This method handles the scrolling so that colors don't fuck up because of the
  /// bouncing scroll physics

  void _listener() {
    if (controller.offset < height * 0.4 && color == Color.fromRGBO(255, 250, 192, 1.0)) {
      setState(() {
        color = Color.fromRGBO(80, 163, 135, 1.0);
      });
    }
    if (controller.offset > height * 1 && color == Color.fromRGBO(80, 163, 135, 1.0)) {
      setState(() {
        color = Color.fromRGBO(255, 250, 192, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(height / 13),
          child: AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              elevation: 0,
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
              title: Text(
                  AppLocalizations.of(context)!.statistics,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 52.3,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500
                  )
              )
          ),
        ),
        body: body
    );
  }
}
