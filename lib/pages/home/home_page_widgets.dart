import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:focus/utils/string_utils.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';
import 'package:focus/pages/plants/plants_page.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/pages/sounds/sounds_page.dart';
import 'package:focus/pages/sounds/sounds_page_widgets.dart';
import 'package:focus/pages/friends/friends_page_widgets.dart';

import 'package:focus/stats/stats.dart';

import 'package:focus/models/models.dart';
import 'package:focus/files/files.dart';
import 'package:focus/timeline/timeline.dart';
import 'package:focus/utils/panel.dart';
import 'package:focus/utils/timer_utils.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:focus/utils/color_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:focus/utils/coins_utilities.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:focus/utils/date_utils.dart';
import 'package:focus/utils/image_utils.dart';
import 'package:focus/utils/messages_utils.dart';
import 'package:share/share.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

/// This list represents the different items of the drawer

var drawerItems = (BuildContext context) => [
  DrawerItem(
      AppLocalizations.of(context)!.statistics,
      "statistical.png"
  ),
  DrawerItem(
      AppLocalizations.of(context)!.plants,
      "plant.png"
  ),
  DrawerItem(
      AppLocalizations.of(context)!.sounds,
      "sounds.png"
  ),
  DrawerItem(
      AppLocalizations.of(context)!.activities,
      "tag.png"
  ),
  DrawerItem(
      AppLocalizations.of(context)!.calendar,
      "calendar.png"
  ),
  DrawerItem(
      AppLocalizations.of(context)!.friends,
      "friends.png"
  ),
  DrawerItem(
      AppLocalizations.of(context)!.realTrees,
      "forest.png"
  ),
  DrawerItem(
      AppLocalizations.of(context)!.settings,
      "settings.png"
  )
];

/// This class represents an item inside the drawer

class DrawerItem {

  /// The title of the item
  final String title;
  /// The path to the item's icon
  final String iconPath;

  const DrawerItem(String title, String iconPath)
      :   this.title = title,
        this.iconPath = "resources/images/drawer/" + iconPath;
}

/// This class represents the drawer, the menu that gets opened when the user clicks
/// the top left icon of the app bar

class CustomDrawer extends StatelessWidget {

  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width / 2,
      child: Drawer(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            /// The number is nine because the first element is a blank space
            itemCount: 9,
            itemBuilder: (context, index) {
              if (index == 0) {
                /// Initial blank space
                return SizedBox(height: height / 15);
              }
              /// The icons to the eight different pages
              return Container(
                height: height / 10,
                margin: EdgeInsets.only(left: width / 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        /// Close the drawer, so that when the user closes the new
                        /// page it doesn't reappear
                        Navigator.pop(context);
                        /// Open the new page
                        Navigator.pushNamed(context, "${--index}");
                      },
                      child: ListTile(
                        leading: Image(
                          image: AssetImage(
                            drawerItems(context)[index - 1].iconPath
                          ),
                          height: height / 27
                        ),
                        title: Text(
                          "${drawerItems(context)[index - 1].title}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: height / 47
                          )
                        )
                      )
                    ),
                  ]
                ),
              );
            }
            )
        )
      )
    );
  }
}

/// This class represents the widget used to switch from single to multi focus mode,
/// which is located at the center of the app bar

class SingleMultipleWidget extends StatefulWidget {

  const SingleMultipleWidget({Key? key}) : super(key: key);

  @override
  _SingleMultipleWidgetState createState() => _SingleMultipleWidgetState();
}

/// This class represents the state of the above widget

class _SingleMultipleWidgetState extends State<SingleMultipleWidget> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<SingleMultipleModel>(
          builder: (context, model, child) {
            return Row(
              children: [
                GestureDetector(
                  /// Single player
                  child: _SingleMultipleOption(
                    true,
                    model.single
                  ),
                  onTap: () {
                    if (model.single) return;
                    model.single = (true);
                  }
                ),
                GestureDetector(
                  /// Multi player
                  child: _SingleMultipleOption(
                    false,
                    !model.single
                ),
                  onTap: () {
                    if (!model.single) return;
                    model.single = (false);
                  }
                )
              ]
            );
          }
        ),
      ],
    );
  }
}

/// This class represents each of the two parts of which the above widget is
/// made of

class _SingleMultipleOption extends StatelessWidget {

  /// Whether it is the single or the multi focus option
  final bool single;
  /// Whether it is active or not
  final bool active;

  const _SingleMultipleOption(this.single, this.active);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width / 8.25,
      height: height / 25,
      decoration: BoxDecoration(
        color: active
          ? Color.fromRGBO(93, 175, 118, 1)
          : Color.fromRGBO(212, 213, 153, 1),
        borderRadius: single
          ? BorderRadius.horizontal(left: Radius.circular(height / 36))
          : BorderRadius.horizontal(right: Radius.circular(height / 36))
        ),
      child: Icon(
        single
            ? Icons.person
            : Icons.people,
        color: Colors.white,
        size: height / 40
      )
    );
  }
}

/// This class represents the widget indicating the amount of money the user has,
/// which is located at the top right of the app bar

class CoinsWidget extends StatelessWidget {

  const CoinsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTablet = height > 1200;
    return Container(
      width: width / 5.25,
      height: height / 25,
      margin: EdgeInsets.only( right: width / 30, top: height / (isTablet ? 80 : 60), bottom: height / (isTablet ? 80 : 60)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 36),
        color: Color.fromRGBO(212, 213, 153, 1)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            " $coins ",
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: Colors.white,
              fontSize: height / 55,
              fontWeight: FontWeight.w400
            )
          ),
          Icon(
            Icons.monetization_on,
            color: Color.fromRGBO(255, 251, 0, 1.0),
            size: height / 45
          )
        ]
      )
    );
  }
}

/// This class represents the app bar widget, which handles each of the states in
/// which the app can be found

class CustomAppBar extends StatelessWidget {

  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MenuModel provider =  Provider.of<MenuModel>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer2<SingleMultipleModel, TimerStatusModel>(
          builder: (context, model, model2, child) {
            switch (model2.status) {
              /// If the timer hasn't started
              case TimerStatus.WAITING:
                if (!model.single && model.createOrJoin != "") {
                  return AppBar(
                      backgroundColor: Colors.transparent,
                      systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
                      elevation: 0,
                      centerTitle: true,
                      /// The drawer icon
                      leading: Builder(
                          builder: (context) {
                            return IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Color.fromRGBO(64, 133, 110, 1),
                                  size: height / 35,
                                ),
                                splashRadius: 0.1,
                                onPressed: () {
                                  model.single = false;
                                  model.createOrJoin = "";
                                  if (key.value != "") {
                                    FirebaseMessaging.instance.unsubscribeFromTopic(key.value);
                                    sendPushMessage(
                                        body: jsonEncode({
                                          "email": getEmail(context)
                                        }),
                                        topic: key.value,
                                        type: "leave"
                                    );
                                    key.value = "";
                                    roomCompanions.value = List.empty(growable: true);
                                  }
                                }
                            );
                          }
                    ),
                    title: UsersAvatarsWidget(),
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(right: height / 61),
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Icon(
                              Icons.people,
                            color: Color.fromRGBO(80, 163, 135, 1),
                            size: height / 30,
                          ),
                        ),
                      )
                    ],
                  );
                }
                return PreferredSize(
                  preferredSize: Size.fromHeight(height / 14.6),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
                    elevation: 0,
                    centerTitle: true,
                    /// The drawer icon
                    leading: Builder(
                      builder: (context) {
                        return IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: Color.fromRGBO(64, 133, 110, 1),
                            size: height / 25,
                          ),
                          splashRadius: 0.1,
                          onPressed: () => Scaffold.of(context).openDrawer()
                        );
                      }),
                    /// The single or multi player switcher
                    title: SingleMultipleWidget(),
                    /// The coin widget
                    actions: [
                      CoinsWidget()
                    ]
                  ),
                );
              /// If the timer has started or it's counting a break
              /// Todo: In single mode, add a motivational sentence
              case TimerStatus.STARTED:
              case TimerStatus.BREAK:
                return PreferredSize(
                  preferredSize: Size.fromHeight(height / 14.6),
                  child: AppBar(
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
                      /// The activity selector icon
                    leading: IconButton(
                      icon: Icon(
                        Icons.label,
                        color: Color.fromRGBO(64, 133, 110, 1),
                        size: height / 30
                      ),
                      onPressed: () {
                        provider.activities = true;
                        provider.sounds = false;
                        panelController.animatePanelToPosition(
                          1,
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.linearToEaseOut
                        );
                      }
                    ),
                    /// The sounds selector icon
                    actions: [
                      Padding(padding: EdgeInsets.only(right: width / 180),
                        child: IconButton(
                          icon: Icon(
                            Icons.music_note,
                            color: Color.fromRGBO(64, 133, 110, 1),
                            size: height / 30,
                          ),
                          onPressed: () {
                            provider.activities = false;
                            provider.sounds = true;
                            panelController.animatePanelToPosition(
                              1,
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.linearToEaseOut
                            );
                          }
                        )
                      )
                    ],
                    title: !model.single && model.createOrJoin != "" ? UsersAvatarsWidget() : null,
                  ),
                );
              /// If the timer is canceled or has finished
              /// Todo: Add a compliment or a scolding
              case TimerStatus.CANCELED:
              case TimerStatus.FINISHED:
                return Container();
            }
          }
        ),
      ],
    );
  }
}

/// This class represents the widget located at the center of the multi player
/// app bar, which displays the avatars of the users in the current room

class UsersAvatarsWidget extends StatelessWidget {

  const UsersAvatarsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerStatusModel>(context, listen: false).status == TimerStatus.WAITING;
    return ValueListenableBuilder<List<String>>(
      /// Get the current room
        valueListenable: roomCompanions,
        /// Build the avatars
        builder: (context, value, child) {
          /// A future builder inside a stream builder is needed in order
          /// to show the loaded avatars of the users
          if (value.length <= 0) {
            return CupertinoActivityIndicator();
          } else {return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: height / 49),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (timer) GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "5");
                        },
                        child: CircleAvatar(
                          backgroundColor: Color.fromRGBO(80, 163, 135, 1),
                          radius: height / 48,
                          child: CircleAvatar(
                            radius: height / 49,
                            backgroundColor: Color.fromRGBO(251, 246, 181, 1),
                            child: Icon(
                              Icons.add,
                              color: Color.fromRGBO(80, 163, 135, 1),
                              size: height / 45,
                            ),
                          ),
                        ),
                      ),
                      if (timer) SizedBox(width: 5),
                      /// The avatar of the first person
                      GestureDetector(
                        child: UserAvatar(
                            image: "",
                            firstLetter: value[0][0]
                        ),
                        onTap: () => Scaffold.of(context).openEndDrawer(),
                      ),
                      /// The avatar of the second person
                      if (value.length > 1) ...[SizedBox(width: 5),
                        GestureDetector(
                            child: UserAvatar(
                                image: "",
                                firstLetter: value[1][0]),
                            onTap: () => Scaffold.of(context).openEndDrawer()
                        )],
                      /// The avatar of the third person
                      if (value.length == 3) ...[SizedBox(width: 5),
                        GestureDetector(
                            child: UserAvatar(
                                image: "",
                                firstLetter: value[2][0]),
                            onTap: () => Scaffold.of(context).openEndDrawer()
                        )],
                      if (value.length > 3) ...[
                        GestureDetector(
                          onTap: () => Scaffold.of(context).openEndDrawer(),
                          child: Text(
                            "  ...",
                            style: TextStyle(
                                color: Colors.black54
                            ),
                          ),
                        )
                      ]
                    ]
                ),
                SizedBox(height: height / 75)
              ]
          );
          }
        }
    );
  }
}

/// This class represents the hill located at the bottom of the page

class HillWidget extends CustomClipper<Path> {

  @override
  getClip(Size size) {
    return Path()
      ..lineTo(0, 0)
      ..lineTo(0, height / 24.4)
      ..quadraticBezierTo(size.width / 4, 0, size.width / 2, 0)
      ..quadraticBezierTo(size.width - size.width / 4, 0, size.width, height / 24.4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

/// This class represents the upper darker border of the hill

class HillDecorationWidget extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path()
      ..lineTo(0, 0)
      ..lineTo(0, height / 24.4)
      ..quadraticBezierTo(size.width / 4, 0, size.width / 2, 0)
      ..quadraticBezierTo(size.width - size.width / 4, 0, size.width + 5, height / 24.4);
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth= 30.0
      ..color = Color.fromRGBO(64, 133, 110, 1);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// This class represents the stack containing the plant, the hill and the main
/// button(s), which is located at the bottom of the page

class PlantHillButtonWidget extends StatefulWidget {

  const PlantHillButtonWidget({Key? key}) : super(key: key);

  @override
  _PlantHillButtonWidgetState createState() => _PlantHillButtonWidgetState();
}

/// This class represents the state of the above widget

class _PlantHillButtonWidgetState extends State<PlantHillButtonWidget> {

  @override
  Widget build(BuildContext context) {
    final provider1 = Provider.of<TimerStatusModel>(context);
    return Container(
      height: height / 2,
      child: Stack(
        children: [
          /// The hill
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: HillWidget(),
                child: Container(
                  width: width,
                  height: height / 3.25,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor
                  ),
                  child: CustomPaint(
                      painter: HillDecorationWidget()
                  )
                )
            )
          ),
          /// The plant
          /// Todo: If timer is canceled, display a dead tree instead through a consumer
          Consumer<MenuModel>(
            builder: (context, model, child) {
              return Positioned(
                  bottom: height / 3.3,
                  left: width / 2 - width / 6,
                  child: GestureDetector(
                    onTap: () {
                      final provider2 = Provider.of<MenuModel>(context, listen: false);
                      /// To open the default menu, not the activities or sounds one
                      provider2.activities = false;
                      provider2.sounds = false;
                      /// Open the default menu only if the timer hasn't started
                      if (provider1.status == TimerStatus.WAITING)
                        panelController.animatePanelToPosition(
                            0.77,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.linearToEaseOut
                        );
                    },
                    child: Image.asset(
                      provider1.status != TimerStatus.CANCELED
                            ? "resources/images/plants/${model.selectedTree}.png"
                            : "resources/images/general/dead-tree.png",
                        height: height / 6.87,
                      width: width / 3,
                    ),
                  )
              );
            }
          ),
          /// The button
          HillButtonWidget()
        ]
      )
    );
  }
}

/// This class represents the buttons which handle each of the states in which
/// the app can be found and are located inside the hill

class HillButtonWidget extends StatefulWidget {

  const HillButtonWidget({Key? key}) : super(key: key);

  @override
  _HillButtonWidgetState createState() => _HillButtonWidgetState();
}

/// This class represents the state of the above widget

class _HillButtonWidgetState extends State<HillButtonWidget> {

  int _selectedBreak = 5;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MenuModel provider = Provider.of<MenuModel>(context, listen: false);
    return Consumer2<SingleMultipleModel, TimerStatusModel>(
      builder: (context, model, model2, child) {
        switch (model2.status) {
          /// If the timer hasn't started
          case TimerStatus.WAITING:
            /// If the single player mode is selected
            if (model.single) {
              /// The button displayed in single mode while in the home page
              return Positioned(
                bottom: height / 8,
                left: width / 2 - width / 6,
                width: width / 3,
                child: CustomButton(
                  text: AppLocalizations.of(context)!.plant.toUpperCase(),
                  textSize: height / 48.8,
                  onPressed: () {
                    /// Start timer
                    if (provider.selectedTimer) startTimer(context);
                    /// Or start chronometer
                    else startChronometer(context);
                  }
                )
              );
            /// If the multi player mode is selected
            } else {
              /// The buttons displayed in multi mode while in the home page
              if (model.createOrJoin == "")
              return Positioned(
                bottom: height / 8,
                child: Container(
                  width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: AppLocalizations.of(context)!.createRoom,
                          textSize: height / 60,
                          /// Todo: Add the actual multi player mode
                          onPressed: () {
                            model.createOrJoin = "Create";
                          }
                        ),
                        SizedBox(width: width / 10),
                        CustomButton(
                          text: AppLocalizations.of(context)!.joinRoom,
                          textSize: height / 60,
                          /// Todo: Add the actual multi player mode and the dialog to insert the room code
                          onPressed: () {
                            showFadingDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (_) => EnterRoomCodeDialog(),
                                duration: Duration(milliseconds: 500),
                                curve: Curves.linearToEaseOut
                            );
                          }
                        )
                      ]
                    )
                )
              );
              return Positioned(
                  bottom: height / 14,
                  left: width / 2 - width / 6,
                  width: width / 3,
                  child: GestureDetector(
                    onTap: () {
                      Share.share(
                          "${Platform.isIOS ? "https://apps.apple.com/app/timey-focus-timer/id1617516028" : "https://play.google.com/store/apps/details?id=com.focus.mobile.focus"}\n\n${AppLocalizations.of(context)!.shareText} ${key.value}");
                    },
                    child: Column(
                        children: [
                            RoomCodeWidget(started: false,),
                            SizedBox(height: height / 146),
                            /// Todo: Add the possibility to share the code
                            Icon(
                                Icons.share,
                                color: Colors.white,
                                size: height / 48.8
                            )
                          ]
                      ),
                  )
                );
            }
          /// If the timer has started or it's counting the break
          case TimerStatus.STARTED:
          case TimerStatus.BREAK:
            /// If the single player mode is selected
            if (model.single) {
              /// The button displayed in single mode while the timer is going
              return Positioned(
                bottom: height / 8,
                left: width / 2 - width / 6,
                width: width / 3,
                child: CustomButton(
                  text: AppLocalizations.of(context)!.cancel.toUpperCase(),
                  color: Color.fromRGBO(213, 95, 95, 1.0),
                  onPressed: () {
                    /// Open the dialog to confirm giving up
                    showFadingDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (_) => GiveUpDialog(),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linearToEaseOut
                    );
                  }
                )
              );
            /// If the multi player mode is selected
            } else {
              /// The buttons displayed in multi mode while the timer is going
              return Positioned(
                bottom: height / 14,
                left: width / 2 - width / 6,
                width: width / 3,
                child: GestureDetector(
                  onTap: () {
                    Share.share(
                        "${Platform.isIOS ? "https://apps.apple.com/app/timey-focus-timer/id1617516028" : "https://play.google.com/store/apps/details?id=com.focus.mobile.focus"}\n\n${AppLocalizations.of(context)!.shareText} ${key.value}");
                  },
                  child: Column(
                    children: [
                      RoomCodeWidget(started: true,),
                      SizedBox(height: height / 146),
                      /// Todo: Add the possibility to share the code
                      Icon(
                        Icons.share,
                        color: Colors.white,
                        size: height / 48.8
                      )
                    ]
                  ),
                )
              );
            }
          /// If the timer is canceled or is finished
          case TimerStatus.CANCELED:
          case TimerStatus.FINISHED:
          /// The buttons displayed after the timer ends or is canceled
          return Positioned(
            bottom: height / 8,
            child: Container(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  model2.status == TimerStatus.FINISHED
                  /// If the session was completed, displays the break button
                  /// Todo: Add the possibility to choose the break duration
                      ? CustomCircledButton(
                          icon: Icons.timer,
                          onPressed: () {
                            showFadingDialog(
                                context: context,
                              barrierDismissible: true,
                              duration: Duration(milliseconds: 500),
                              builder: (context) {
                                  return CustomDialogBase(
                                      titleIcon: Icon(Icons.timer, color: Colors.white, size: height / 21,),
                                      body: Column(
                                        children: [
                                          SizedBox(height: height / 75,),
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: width / 15),
                                            child: Text(
                                              AppLocalizations.of(context)!.selectBreakDuration,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: height / 46,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600
                                              )
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: width / 25, vertical: height / 65),
                                            height: height / 5,
                                            child: CupertinoPicker(
                                              scrollController: FixedExtentScrollController(initialItem: 4),
                                              onSelectedItemChanged: (int value) {
                                                _selectedBreak = value + 1;
                                              },
                                              itemExtent: height / 16,
                                              children: [
                                                ...List.generate(15, (index) {
                                                  return Column(
                                                    children: [
                                                      SizedBox(height: 12),
                                                      Text(
                                                        "${++index}m",
                                                        style: TextStyle(
                                                          color: Colors.black45,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: height / 44
                                                        ),
                                                      ),
                                                      SizedBox(height: 7)
                                                    ],
                                                  );
                                                })
                                              ],
                                            ),
                                          ),
                                          CustomButton(
                                              text: AppLocalizations.of(context)!.start,
                                              textSize: height / 46,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                final provider = Provider.of<MenuModel>(context, listen: false);
                                                provider.shortBreakDuration = _selectedBreak;
                                                provider.selectedPomodoro = false;
                                                model2.status = TimerStatus.BREAK;
                                                startTimer(context);
                                              }
                                              )
                                        ],
                                      )
                                  );
                              }
                            );
                          }
                 /// If the session was canceled, displays the repeat button
                  ) : CustomCircledButton(
                        icon: Icons.refresh_sharp,
                        onPressed: () async {
                          if (key.value != "") {
                            await FirebaseFirestore.instance
                                .collection("rooms")
                                .doc(key.value)
                                .update({
                              "failed": false,
                              "succeeded": false,
                              "failer": "",
                              "started": true,
                              "startedTime": DateTime.now().millisecondsSinceEpoch ~/ 1000
                            });
                          }
                          startTimer(context);
                        }
                  ),
                  /// The close button to go back to the home page
                  CustomCircledButton(
                    icon: Icons.close,
                    onPressed: () {
                      reasonsSelected = [false, false, false, false, false, false];
                      model2.status = TimerStatus.WAITING;
                    }
                  ),
                  /// The edit button to:
                  /// - if the session was completed: write what you did
                  /// - if the session was canceled: write why you failed
                  CustomCircledButton(
                    icon: Icons.edit,
                    onPressed: () {
                     showFadingDialog(
                       context: context,
                       builder: (context) => model2.status == TimerStatus.FINISHED ? SessionSummaryDialog() : FailureReasonDialog(),
                       duration: Duration(milliseconds: 300),
                       curve: Curves.linearToEaseOut,
                       barrierDismissible: true
                     ); // write why you failed
                    }
                  )
                ]
              )
            )
          );
        }
      }
    );
  }
}

/// The key of the room the user is in
/// If not in a room, returned value is ""

ValueNotifier<String> key = ValueNotifier<String>("");

/// This class represents the text which lets you create a new group session room

class RoomCodeWidget extends StatefulWidget {

  /// Whether the group session has started

  final bool started;

  const RoomCodeWidget({Key? key, required this.started}) : super(key: key);

  @override
  _RoomCodeWidgetState createState() => _RoomCodeWidgetState();
}

class _RoomCodeWidgetState extends State<RoomCodeWidget> {

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS && !loading) {
      flutterLocalNotificationsPlugin.show(
          1039492,
          AppLocalizations.of(context)!.featureAvailableSoon,
          AppLocalizations.of(context)!.featureAvailableSoonSub,
          platformChannelSpecifics
      );
      Future.delayed(Duration(seconds: 1), () {
        flutterLocalNotificationsPlugin.cancel(1039492);
      });
    }
    MenuModel provider =  Provider.of<MenuModel>(context, listen: false);
    /// If the room does not exist, create one
    return FutureBuilder<String>(
      future: key.value == "" ? createRoom(context) : Future.value(key.value),
      builder: (context, value) {
        return Column(
          children: [
            /// Cancel button
            widget.started ? CustomButton(
                text: AppLocalizations.of(context)!.cancel.toUpperCase(),
                color: Color.fromRGBO(213, 95, 95, 1.0),
                /// Todo: Add to the dialog that it will kill other people's tree
                onPressed: () {
                  /// Open the dialog to confirm giving up
                  showFadingDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (_) => GiveUpDialog(),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linearToEaseOut
                  );
                }
                /// Plant button
            ) : CustomButton(
                text: " ${AppLocalizations.of(context)!.plant.toUpperCase()}",
                textSize: height / 48.8,
                loading: loading,
                /// Todo: Add to the dialog that it will kill other people's tree
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  final b = Provider.of<TimerModel>(context, listen: false);
                  await sendPushMessage(
                    topic: key.value,
                    type: 'start',
                    body: jsonEncode({
                      "startedTime": DateTime.now().millisecondsSinceEpoch,
                      "duration": b.selectedMinutes,
                      "timer": provider.selectedTimer,
                      "deep": provider.selectedDeepFocus,
                      "pomodoro": provider.selectedPomodoro,
                      "shortBreak": provider.shortBreakDuration,
                      "longBreak": provider.longBreakDuration,
                      "repetitions": provider.repetitions
                    }),
                  );
                  loading = false;
                  if (mounted) setState(() {});
                }
            ),
            value.hasData && value.data != ""
                ? Padding(
                padding: EdgeInsets.only(top: height / 73.2),
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: AppLocalizations.of(context)!.thisIsYourCode,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: height / 66.5
                        ),
                        children: [
                          TextSpan(
                              text: "\n${value.data}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height / 48.8,
                                  fontWeight: FontWeight.w800
                              )
                          )
                        ]
                    )
                )
            ) :  Container(
                margin: EdgeInsets.all(height / 73),
                child: CupertinoActivityIndicator()
            )
          ]
        );
      }
    );
  }
}

/// This class represents a custom button with the app's style

class CustomButton extends StatelessWidget {

  /// The text of the button
  final String text;
  /// The color of the button
  final Color color;
  /// The size of the button's text
  final double textSize;
  /// The action to perform when the button is clicked
  final void Function() onPressed;
  final bool loading;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.color = const Color.fromRGBO(161, 228, 163, 0.8),
    this.textSize = -1,
    this.loading = false
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        /// No splash animation because of the color change from green to red
        splashFactory: NoSplash.splashFactory,
        shadowColor: MaterialStateProperty.all<Color>(Colors.black87),
        overlayColor: MaterialStateProperty.all<Color>(color),
        backgroundColor: MaterialStateProperty.all<Color>(color),
        /// Shadow intensity
        elevation: MaterialStateProperty.all<double>(4.5),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(height / 50)))
        ),
        child: loading ? CupertinoActivityIndicator() : Container(
          margin: EdgeInsets.all(height / 100),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Euclid",
              fontSize: textSize == -1
                  ? height / 52.3
                  : textSize
            )
          ),
        ),
      onPressed: !loading ? onPressed : null
    );
  }
}

/// This class represents a circled button with the app's style

class CustomCircledButton extends StatelessWidget {

  /// The icon of the button
  final IconData icon;
  /// The action to perform when the button is clicked
  final Function() onPressed;

  CustomCircledButton({
    required this.icon,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width / 24),
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: height / 16.26, height: height / 16.26),
        child: RawMaterialButton(
          elevation: 0,
          focusElevation: 0,
          highlightElevation: 0,
          fillColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Center(
            child: Icon(
              icon,
              size: height / 30,
              color: Colors.white
            )
          ),
          shape: CircleBorder(
            side: BorderSide(
              color: Colors.white,
              width: 2
            )
          ),
          onPressed: onPressed
        )
      )
    );
  }
}

/// This variable represents the timer or chronometer

Timer? timer;

/// This variable represents the controller of the circular timer's fade animation

late AnimationController timerController;

/// This class represents the timer widget located at the center of the page

class TimerWidget extends StatefulWidget {

  const TimerWidget({Key? key}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();

}

/// This class represents the state of the above widget

class _TimerWidgetState extends State<TimerWidget> with TickerProviderStateMixin {

  /// Used to animate the timer when it starts or ends

  var _animation;

  @override
  void initState() {
    timerController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 250)
    );
    _animation = Tween<double>(
        begin: 0.0,
        end: 1.0
    ).animate(timerController);
    /// Start the animation
    timerController.forward();
    super.initState();
  }

  @override
  dispose() {
    timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerStatusModel, TimerModel>(
      builder: (context, model, model2, child) {
        MenuModel provider = Provider.of<MenuModel>(context, listen: false);
        /// Whether the user selected the timer or the chronometer
        bool chronometer = !provider.selectedTimer;
        return GestureDetector(
          child: Container(
            alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: _animation,
                child: SleekCircularSlider(
                  /// Todo: Change min value to ten minutes or 600 seconds depending on the status
                  min: provider.selectedTimer ? (model.status != TimerStatus.WAITING ? 0 : 10) : 0,
                  max: model.status == TimerStatus.STARTED || model.status == TimerStatus.BREAK
                      /// If it has started, displays the total seconds
                      ? model2.totalSeconds.toDouble()
                      /// If it hasn't started, displays the maximum minutes (120)
                      : 121,
                  /// The appearance of the slider based on its status
                  appearance: CircularSliderAppearance(
                    size: height / 2.87,
                    angleRange: 360.0,
                    /// Needed for the timer to start from 360 or the chronometer from 0
                    startAngle: 270,
                    /// It is buggy if used as a timer
                    animationEnabled: false,
                    customWidths: CustomSliderWidths(
                      /// The bigger bar
                      progressBarWidth: !chronometer ? height / 145 : 0,
                      /// The smaller bar
                      trackWidth: model.status == TimerStatus.CANCELED || model.status == TimerStatus.FINISHED ? height / 145 : height / 240,
                      shadowWidth: 0,
                      /// The size of the dot or handler
                      handlerSize: model.status != TimerStatus.WAITING || chronometer ? 0 : 12
                    ),
                    customColors: CustomSliderColors(
                      /// The color of the bigger bar
                      progressBarColor: barColor(model.status, context, false, chronometer),
                      /// The color of the smaller bar
                      trackColor: barColor(model.status, context, true, chronometer),
                      /// The color of the dot or handler
                      dotColor: Theme.of(context).primaryColor
                      )
                    ),
                    /// When the dot is dragged and then released, this method sets the new settings
                    onChangeEnd: model.status == TimerStatus.WAITING && !chronometer
                        ? (value) {
                        model2.selectedMinutes = value.toInt().toDouble();
                        model2.totalSeconds = (model2.selectedMinutes * 60);
                        model2.remainingSeconds = (model2.selectedMinutes * 60);
                        if (key.value != "")
                          sendPushMessage(
                            type: "duration",
                            topic: key.value,
                            body: jsonEncode({
                              "duration": (value.toInt() * 60)
                            })
                          );
                      /// Null so that users can't edit time while the timer is going
                      } : null,
                    /// The text inside the circled timer
                    innerWidget: (value) {
                      var minutes = Duration(seconds: model2.remainingSeconds.toInt()).inMinutes;
                      var seconds = model2.remainingSeconds.toInt() - minutes * 60;
                        /// The time text itself
                        return Center(
                          child: Text(
                            timerText(model, minutes, seconds, value),
                            style: TextStyle(
                              color: Color.fromRGBO(63, 110, 95, 1),
                              fontSize: [TimerStatus.FINISHED, TimerStatus.CANCELED].contains(model.status)
                                  ? height / 7.32
                                  : height / 12.62,
                              fontFamily: "Ink"
                            )
                          )
                        );
                      },
                  /// The current value of the timer
                  initialValue: initialValue(model, model2, provider)
                )
              )
            ),
          onTap: () {
            /// To open the default menu, not the activities or sounds one
            provider.activities = false;
            provider.sounds = false;
            /// Open the default menu only if the timer hasn't started
            if (model.status == TimerStatus.WAITING)
              panelController.animatePanelToPosition(
                  0.77,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linearToEaseOut
              );
          }
        );
      }
    );
  }
}



/// This variable represents the controller of the below menu

PanelController panelController = PanelController();

/// The controller of the panel's page view

PageController pageController = PageController();

/// This class represents the menu opened by clicking the timer. It contains all the
/// options to start the session

class CustomSlidingUpPanel extends StatefulWidget {

  /// The body behind the panel

  final Widget body;

  const CustomSlidingUpPanel({required this.body});

  @override
  _CustomSlidingUpPanelState createState() => _CustomSlidingUpPanelState();
}

/// This class represents the state of the above menu

class _CustomSlidingUpPanelState extends State<CustomSlidingUpPanel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pageController = PageController();
    return Consumer<MenuModel>(
      builder: (context, model, child) {
        /// Whether the default menu or a specific one should be opened
        /// e.g. There are three menus, the default one, the activities one and
        /// the sounds one
        var defaultMenu = !model.activities && !model.sounds;
        return SlidingUpPanel(
          controller: panelController,
          color: Theme.of(context).backgroundColor,
          minHeight: 0,
          maxHeight: defaultMenu
            /// Default menu
            ? height * 0.86
            /// Activities or sounds menu
            : height * 0.17,
          borderRadius: defaultMenu
            /// Default panel
            ? BorderRadius.zero
            /// Activities or sounds menu
            : BorderRadius.vertical(top: Radius.circular(height / 18)),
          defaultPanelState: PanelState.CLOSED,
          /// What's under the menu (in our case the entire scaffold)
          body: widget.body,
          /// The widget at the top of the menu
          /// Todo: Add the saved page in the menu
          header: defaultMenu
              ? Container(
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Small white divider that symbolizes draggability
                  SizedBox(
                    width: width / 12,
                    child: Divider(
                    color: Colors.white,
                    thickness: 2
                    )
                  ),
                  SizedBox(
                    height: height / 100
                  ),
                  CreateSavedWidget(
                    nameOne: AppLocalizations.of(context)!.create,
                    nameTwo: AppLocalizations.of(context)!.saved,
                    width: 4,
                    firstIsActive: model.create,
                    /// User wants to create a new profile
                    onTapFirst: () {
                      if (model.create) return;
                      model.create = (true);
                      },
                    /// User wants to use a preexisting profile
                    onTapSecond: () {
                      if (!model.create) return;
                        flutterLocalNotificationsPlugin.show(
                            1039492,
                            AppLocalizations.of(context)!.featureAvailableSoon,
                            AppLocalizations.of(context)!.featureAvailableSoonSub,
                            platformChannelSpecifics
                        );
                        Future.delayed(Duration(seconds: 1), () {
                          flutterLocalNotificationsPlugin.cancel(1039492);
                        });
                      //model.create = (false);
                    }
                    )
              ]
            )
            /// Small white divider that symbolizes draggability
          ) : Container(
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
            /// Make background darker when opening the menu
            backdropEnabled: true,
            backdropOpacity: 0.4,
            /// The content of the menu
            panel: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(height / 18)),
                color: Color.fromRGBO(80, 163, 135, 1.0),
              ),
              child: panelWidget(context, model)
            ),
            onPanelClosed: () {
              if (defaultMenu && model.create) pageController.jumpToPage(0);
            },
            maxPoint: () {
              if (!defaultMenu) {
                return 1.0;
              }
              if (pageController.page?.round() == 0) {
                return 0.77;
              }
              if (!model.selectedPomodoro) {
                return 0.6;
              }
              return 1.0;
            },
        );
      }
    );
  }
}

Widget panelWidget(BuildContext context, MenuModel model) {
  pageController = PageController();
  if (!model.activities && !model.sounds) {
    if (model.create) {
      return PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          scrollDirection: Axis.horizontal,
          children: [
            /// First page
            FirstMenuPage(),
            /// Second page
            SecondMenuPage()
          ]);
    }
    return SavedPage();
  }
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TitleMenuText(
          title: model.activities
              ? AppLocalizations.of(context)!.selectYourActivity
              : "\n${AppLocalizations.of(context)!.selectYourSound}",
          alignment: Alignment.center,
        ),
        SizedBox(height: height / 150),
        model.activities
            ? ActivitiesList(false)
            : SoundsList(),

      ]
  );
}

/// This class represents the first page of the menu

class FirstMenuPage extends StatelessWidget {

  const FirstMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MenuModel>(context, listen: false);
    return Column(
      children: [
        /// Trees or plants selector
        TitleMenuText(
          title: AppLocalizations.of(context)!.yourTrees,
          top: height / 11,
        ),
        TreeList(),
        /// Sounds selector
        TitleMenuText(
          title: AppLocalizations.of(context)!.yourSounds,
          top: height / 30,
        ),
        SoundsList(),
        /// General activities selector
        TitleMenuText(
          title: AppLocalizations.of(context)!.yourActivities,
          top: height / 55,
        ),
        SingleActivityList(
          true
        ),
        SizedBox(height: height / 55),
        /// Specific activities selector
        /*
        TitleMenuText(
          title: AppLocalizations.of(context)!.yourSpecificActivities,
          top: height / 55,
        ),
        SingleActivityList(
          false
        ),
         */
        SizedBox(height: height / 25),
        CustomButton(
          text: ' ${AppLocalizations.of(context)!.next}      ',
          onPressed: () {
            panelController.animatePanelToPosition(!model.selectedPomodoro ? 0.6 : 1.0, duration: Duration(milliseconds: 500), curve: Curves.ease);
            pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
          }
        )
      ]
    );
  }
}

void methodInfo(BuildContext context, String title, String text, [bool unlimited = false]) {
  showFadingDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CustomDialogBase(
            titleIcon: Icon(
              Icons.edit,
              color: Colors.white,
              size: height / 25,
            ),
            body: unlimited ? SizedBox(
              width: width / 2,
              height: height / 5.74,
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (title != "") Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: height / 48,
                      fontWeight: FontWeight.w600
                      )
                  ),
                  Text(
                    "$text",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: height / 52
                    )
                  )
                ],
              ),
            ) : Container(
              margin: EdgeInsets.only(top: height / 29, left: width / 14.5, right: width / 14.5, bottom: height / 49),
              child: Column(
                children: [
                  Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: height / 42,
                          fontWeight: FontWeight.w700
                      )
                  ),
                  Text(
                    "\n$text",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: height / 52
                    ),
                  ),
                ],
              ),
            )
        );
      },
      duration: Duration(milliseconds: 500)
  );
}

/// This class represents the second page of the menu

class SecondMenuPage extends StatelessWidget {

  const SecondMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model2 = Provider.of<TimerModel>(context, listen: false);
    return Consumer<MenuModel>(
      builder: (context, model, child) {
        return ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
          children: [
            /// Chronometer or countdown selector
            Column(
              children: [
                GestureDetector(
                  child: TitleMenuText(
                    title: AppLocalizations.of(context)!.timeCount,
                    top: height / 17.25,
                    alignment: Alignment.center,
                    icon: true,
                  ),
                  onTap: () {
                    methodInfo(
                        context,
                        AppLocalizations.of(context)!.infoCount,
                        AppLocalizations.of(context)!.infoCountSub
                    );
                  },
                ),
                SizedBox(height: height / 45),
                CreateSavedWidget(
                  nameOne: AppLocalizations.of(context)!.countdown,
                  nameTwo: AppLocalizations.of(context)!.chronometer,
                  width: 3,
                  firstIsActive: model.selectedTimer,
                  onTapFirst: () {
                    if (!model.selectedTimer) {
                      model.selectedTimer = true;
                      model2.remainingSeconds = model2.selectedMinutes * 60;
                      /*
                      panelController.animatePanelToPosition(1, duration: Duration(milliseconds: 1000), curve: Curves.linearToEaseOut);
                      model.selectedPomodoro = true;
                       */
                    }
                    if (key.value != "")
                      sendPushMessage(
                          type: "timer",
                          topic: key.value,
                          body: jsonEncode({
                            "timer": true
                          })
                      );
                  },
                  onTapSecond: () {
                    if (model.selectedTimer) {
                      model.selectedTimer = false;
                      model2.remainingSeconds = 0;
                      panelController.animatePanelToPosition(0.6, duration: Duration(milliseconds: 750), curve: Curves.linearToEaseOut);
                      model.selectedPomodoro = false;
                    }
                    if (key.value != "")
                      sendPushMessage(
                          type: "timer",
                          topic: key.value,
                          body: jsonEncode({
                            "timer": false
                          })
                      );
                  },
                ),
                /// Deep focus
                GestureDetector(
                  child: TitleMenuText(
                      title: AppLocalizations.of(context)!.deepFocus,
                      top: height / 45,
                      alignment: Alignment.center,
                      icon: true
                  ),
                  onTap: () {
                    methodInfo(
                        context,
                        AppLocalizations.of(context)!.infoDeep,
                        AppLocalizations.of(context)!.infoDeepSub
                        );
                  },
                ),
                SizedBox(height: height / 45),
                CreateSavedWidget(
                  nameOne: AppLocalizations.of(context)!.on,
                  nameTwo: AppLocalizations.of(context)!.off,
                  width: 3,
                  firstIsActive: model.selectedDeepFocus,
                  onTapFirst: () {
                    if (!model.selectedDeepFocus) model.selectedDeepFocus = true;
                    if (key.value != "")
                      sendPushMessage(
                          type: "deep",
                          topic: key.value,
                          body: jsonEncode({
                            "deep": true
                          })
                      );
                  },
                  onTapSecond: () {
                    if (model.selectedDeepFocus) model.selectedDeepFocus = false;
                    if (key.value != "")
                      sendPushMessage(
                          type: "deep",
                          topic: key.value,
                          body: jsonEncode({
                            "deep": false
                          })
                      );
                  },
                ),
                /// Automatic pomodoro breaks and sessions
                GestureDetector(
                  child: TitleMenuText(
                      title: AppLocalizations.of(context)!.automaticPomodoro,
                      top: height / 45,
                      alignment: Alignment.center,
                      icon: true
                  ),
                  onTap: () {
                    methodInfo(
                        context,
                        AppLocalizations.of(context)!.infoPomodoro,
                        AppLocalizations.of(context)!.infoPomodoroSub
                    );
                  },
                ),
                SizedBox(height: height / 45,),
                CreateSavedWidget(
                  nameOne: AppLocalizations.of(context)!.on,
                  nameTwo: AppLocalizations.of(context)!.off,
                  width: 3,
                  firstIsActive: model.selectedPomodoro,
                  onTapFirst: () {
                    if (!model.selectedPomodoro) {
                      model.selectedPomodoro = true;
                    }
                    model2.remainingSeconds -= model2.remainingSeconds;
              if (key.value != "")
                      sendPushMessage(
                          type: "pomodoro",
                          topic: key.value,
                          body: jsonEncode({
                            "pomodoro": true
                          })
                      );
                  },
                  onTapSecond: () {
                    if (model.selectedPomodoro) model.selectedPomodoro = false;
                    //panelController.animatePanelToPosition(0.6, duration: Duration(milliseconds: 750), curve: Curves.linearToEaseOut);
                    if (key.value != "")
                      sendPushMessage(
                          type: "pomodoro",
                          topic: key.value,
                          body: jsonEncode({
                            "pomodoro": false
                          })
                      );
                  },
                ),
                /// Only if automatic pomodoro is selected, show these sliders
                /// Todo: Add the slider to choose after how many session the long break should start
                if (model.selectedPomodoro) ...[
                  SizedBox(height: height / 45),
                  DurationSlider(
                      min: 10,
                      max: 120,
                      color: Theme.of(context).primaryColor,
                      title: AppLocalizations.of(context)!.focusSession,
                      onChange: (value) {
                        final provider = Provider.of<TimerModel>(context, listen: false);
                        provider.totalSeconds = value.round() * 60;
                        provider.remainingSeconds = value.round() * 60;
                        provider.selectedMinutes = value.round().toDouble();
                        if (key.value != "")
                          sendPushMessage(
                              type: "duration",
                              topic: key.value,
                              body: jsonEncode({
                                "duration": (value.toInt() * 60)
                              })
                          );
                      }
                  ),
                  DurationSlider(
                      min: 1,
                      max: 30,
                      color: Color.fromRGBO(245, 99, 99, 1.0),
                      title: AppLocalizations.of(context)!.shortBreak,
                      onChange: (value) {
                        model.shortBreakDuration = value.toInt();
                        if (key.value != "")
                          sendPushMessage(
                              type: "shortBreak",
                              topic: key.value,
                              body: jsonEncode({
                                "shortBreak": value.toInt()
                              })
                          );
                      }
                  ),
                  DurationSlider(
                      min: 1,
                      max: 30,
                      color: Color.fromRGBO(133, 152, 243, 1.0),
                      title: AppLocalizations.of(context)!.longBreak,
                      onChange: (value) {
                        model.longBreakDuration = value.toInt();
                        if (key.value != "")
                          sendPushMessage(
                              type: "longBreak",
                              topic: key.value,
                              body: jsonEncode({
                                "longBreak": value.toInt()
                              })
                          );
                      }
                  ),
                  DurationSlider(
                      min: 1,
                      max: 16,
                      color: Color.fromRGBO(204, 133, 243, 1.0),
                      title: AppLocalizations.of(context)!.repetitions,
                      onChange: (value) {
                        model.repetitions = value.toInt();
                        if (key.value != "")
                          sendPushMessage(
                              type: "repetitions",
                              topic: key.value,
                              body: jsonEncode({
                                "repetitions": value.toInt()
                              })
                          );
                      }
                  )
                ],
                SizedBox(height: model.selectedPomodoro ? height / 150 : height / 25),
                CustomButton(
                    text: '${AppLocalizations.of(context)!.plant}',
                    onPressed: () {
                      panelController.close();
                      if (model.selectedTimer) startTimer(context);
                      else startChronometer(context);
                    }
                ),
              ]
            )
          ]
        );
      }
    );
  }
}

/// This class represents the widget which lets the user choose if he wants to create
/// a new menu profile or if he wants to use a preexisting one

class CreateSavedWidget extends StatefulWidget {

  /// The names of the two options
  final String nameOne, nameTwo;
  /// Whether the first option is selected
  final bool firstIsActive;
  /// The width of the widget
  final int width;
  /// The actions to perform when the options get clicked
  final Function() onTapFirst, onTapSecond;

  CreateSavedWidget({
    required this.nameOne,
    required this.nameTwo,
    required this.width,
    required this.firstIsActive,
    required this.onTapFirst,
    required this.onTapSecond
  });

  @override
  _CreateSavedWidgetState createState() => _CreateSavedWidgetState();
}

/// This class represents the state of the above widget

class _CreateSavedWidgetState extends State<CreateSavedWidget> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// The first and left option
            GestureDetector(
              child: _NewSavedOption(
                first: true,
                active: widget.firstIsActive,
                nameOne: widget.nameOne,
                nameTwo: widget.nameTwo,
                widthFactor: widget.width
              ),
              onTap: widget.onTapFirst
            ),
            /// The second and right option
            GestureDetector(
              child: _NewSavedOption(
                first: false,
                active: !widget.firstIsActive,
                nameOne: widget.nameOne,
                nameTwo: widget.nameTwo,
                widthFactor: widget.width
              ),
              onTap: widget.onTapSecond
            )
          ]
        )
      ]
    );
  }
}

/// This class represents one of the two options of the above widget

class _NewSavedOption extends StatelessWidget {

  /// The name of the two options
  final String nameOne, nameTwo;
  /// Whether it's the first or second option
  final bool first;
  /// Whether the option is active
  final bool active;
  /// The width of the option widget
  final int widthFactor;

  const _NewSavedOption({
    required this.nameOne,
    required this.nameTwo,
    required this.first,
    required this.active,
    required this.widthFactor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width / widthFactor,
        height: height / 35,
        decoration: BoxDecoration(
            color: active
                ? Theme.of(context).primaryColor
                : Color.fromRGBO(150, 151, 144, 1.0),
            borderRadius: first
                ? BorderRadius.horizontal(left: Radius.circular(height / 36))
                : BorderRadius.horizontal(right: Radius.circular(height / 36))
        ),
        child: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      first
                          ? nameOne
                          : nameTwo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: height / 66.5,
                          fontWeight: FontWeight.w600
                      )
                  )
                ]
            )
        )
    );
  }
}

/// This class represents the title of a section of the menu

class TitleMenuText extends StatelessWidget {

  /// The title
  final String title;
  /// Padding from the top
  final double top;
  /// Alignment of the title
  final Alignment alignment;
  /// Color
  final Color color;
  /// Text size
  final double size;
  /// Display icon
  final bool icon;

  const TitleMenuText({
    this.top = 0,
    required this.title,
    this.alignment = Alignment.topLeft,
    this.color = Colors.white,
    this.size = -1,
    this.icon = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(left: alignment != Alignment.center ? width / 26 : 0, top: top),
      child: Row(
        mainAxisAlignment: alignment == Alignment.center ?  MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (icon) SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: size == -1 ? height / 56.3 : size,
              fontWeight: FontWeight.w500
            )
          ),
          if (icon) ...[
            SizedBox(width: 5),
            Icon(
                Icons.info_outline,
                color: Colors.white,
                size: height / 49
            ),
          ]
        ],
      )
    );
  }
}

/// This class represents the list of tree options contained in the menu
/// Todo: Add the actual trees and the market icon to unlock a new tree

class TreeList extends StatefulWidget {

  const TreeList({Key? key}) : super(key: key);

  @override
  _TreeListState createState() => _TreeListState();
}

/// This class represents the state of the above widget

class _TreeListState extends State<TreeList> {

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuModel>(
      builder: (context, model, child) {
        return Container(
          height: height / 9,
          margin: EdgeInsets.only(top: height / 48.8),
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
              if (index == 6) return SizedBox(width: width / 20);
              return GestureDetector(
                child: Container(
                    margin: EdgeInsets.only(
                      left: width / 26
                    ),
                    width: height / 9,
                    decoration: BoxDecoration(
                      color: model.selectedTree != index
                        ? Colors.white.withOpacity(0.7)
                        : Colors.white,
                      borderRadius: BorderRadius.circular(height / 48)
                    ),
                    child: Center(
                      child: Image.asset(
                        "resources/images/plants/$index.png",
                        height: height / 14.64
                      )
                    )
                ),
                onTap: () {
                  final isUnlocked = plantsUnlocked.contains(plantNames[index]);
                  if (isUnlocked) {
                    model.selectedTree = index;
                  } else {
                    showFadingDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => CustomDialogBase(
                            titleIcon: Icon(
                              Icons.vpn_key,
                              color: Colors.white,
                              size: height / 21
                            ),
                            body: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: height / 40.6, left: width / 36, right: width / 36, bottom: height / 40.6),
                                  child: Text(
                                    "Oops!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: height / 45,
                                        fontWeight: FontWeight.w600
                                    ),),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: width / 24, right: width / 24, top: height / 244, bottom: height / 36.5),
                                  child: Text(
                                    "You haven't unlocked this plant yet",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: height / 52,
                                        fontWeight: FontWeight.w400
                                    ),),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomButton(
                                        text: "${AppLocalizations.of(context)!.cancel}",
                                        color: Colors.grey.withOpacity(0.5),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        }),
                                    CustomButton(
                                        text: AppLocalizations.of(context)!.unlock,
                                        onPressed: () async {
                                          Navigator.popAndPushNamed(context, "1");
                                          /*
                                          Future.delayed(Duration(milliseconds: 50), () {
                                            plantController.animateToPage(index, duration: Duration(milliseconds: 750), curve: Curves.linearToEaseOut);
                                          });
                                           */
                                        }),
                                  ],
                                )
                              ],
                            )
                        ),
                        duration: Duration(milliseconds: 500)
                    );
                  }
                }
              );
            }
          )
        );
      }
    );
  }
}

/// This class represents the list of unlocked sounds contained in the menu
/// Todo: Add the actual sounds, an icon for each of them and the market icon to
/// Todo: unlock a new sound

class SoundsList extends StatefulWidget {

  const SoundsList({Key? key}) : super(key: key);
  @override
  _SoundsListState createState() => _SoundsListState();
}

/// This class represents the state of the above widget

class _SoundsListState extends State<SoundsList> {

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            Container(
              height: height / 12,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                itemBuilder: (context, index) {
                  if (index == 7) return SizedBox(width: width / 20,);
                  return Container(
                    padding: EdgeInsets.only(left: width / 26),
                    child: ChoiceChip(
                      label: Container(
                        margin: EdgeInsets.all(height / 275),
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              size: height / 48.8
                            ),
                            Text(
                              index == 0 ? " None" : " " + "${sounds[index - 1]}".toCamelCase(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: height / 61
                              )
                            )
                          ]
                        ),
                      ),
                      backgroundColor: Color.fromRGBO(222, 222, 222, 1.0),
                      selectedColor: Colors.white,
                      selected: index == model.selectedSound,
                      onSelected: (selected) {
                        if (index == 0 && selected) {
                          model.selectedSound = 0;
                          if (model.sounds) {
                            player.stop();
                          }
                          return;
                        }
                        final isUnlocked = soundsUnlocked.contains(sounds[index - 1]);
                        if (isUnlocked) {
                          if (selected) model.selectedSound = (index);
                          if (model.sounds) {
                            player.stop();
                            playSound(model);
                          }
                        } else {
                          showFadingDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) => CustomDialogBase(
                                  titleIcon: Icon(
                                      Icons.vpn_key,
                                      color: Colors.white,
                                      size: height / 21
                                  ),
                                  body: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: height / 40.5, left: width / 36, right: width / 36, bottom: height / 73),
                                        child: Text(
                                          "Oops!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: height / 45,
                                              fontWeight: FontWeight.w600
                                          ),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: width / 24, right: width / 24, top: height / 244, bottom: height / 36.5),
                                        child: Text(
                                          "You haven't unlocked this sound yet",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: height / 52,
                                              fontWeight: FontWeight.w400
                                          ),),
                                      ),
                                      Provider.of<TimerStatusModel>(context, listen: false).status != TimerStatus.WAITING ? CustomButton(
                                          text: AppLocalizations.of(context)!.gotIt,
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          }) : Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          CustomButton(
                                            text: AppLocalizations.of(context)!.cancel,
                                            color: Colors.grey.withOpacity(0.5),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            }
                                          ),
                                          CustomButton(
                                            text: AppLocalizations.of(context)!.unlock,
                                            onPressed: () async {
                                              Navigator.popAndPushNamed(context, "2");
                                          })
                                        ],
                                      ),
                                    ],
                                  )
                              ),
                              duration: Duration(milliseconds: 500)
                          );
                        }
                      }
                    )
                  );
                }
              )
            )
          ]
        );
      }
    );
  }
}

/// This class represents the list of activities contained in the menu
/// Todo: Add the create activity button

class ActivitiesList extends StatefulWidget {

  final bool add;

  const ActivitiesList([this.add = true]);

  @override
  _ActivitiesListState createState() => _ActivitiesListState();
}

/// This class represents the state of the above widget

class _ActivitiesListState extends State<ActivitiesList> {

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            /// This is the general activity categories (study, read, work, sport ecc)
            SingleActivityList(true, widget.add),
            /*
             /// This is the specific activity category (for study, you have every subject, for sport you have every game ecc.)
            SingleActivityList(false, widget.add)
             */
          ]
        );
      }
    );
  }
}

/// This class represents the single list of general or specific activities

class SingleActivityList extends StatelessWidget {

  /// Whether this list is for general or specific activities

  final bool isGeneral;
  final bool add;

  const SingleActivityList(this.isGeneral, [this.add = true]);

  @override
  Widget build(BuildContext context) {
    MenuModel provider = Provider.of<MenuModel>(context, listen: false);
    return Consumer<ActivitiesModel>(
      builder: (context, provider2, child) {
        final generalActivity = provider2.activities["general"][provider.selectedGeneralActivity - 1];
        final specificActivities = provider2.activities["specific"][generalActivity.name];
        return Container(
            height: height / 23,
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: height / 55),
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: isGeneral
                    ? provider2.activities["general"].length + 2
                    : specificActivities.length + 1,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (index == provider2.activities["general"].length + 1) return SizedBox(width: width / 20,);
                  if (index == 0) {
                    return add ? Container(
                      margin: EdgeInsets.only(left: width / 26),
                      child: ChoiceChip(
                        selected: false,
                        label: Icon(Icons.add, size: height / 45),
                        onSelected: (selected) {
                          Navigator.pushNamed(context, "3");
                        },
                      )
                    ) : Container(width: 0, height: 0);
                  }
                  return Container(
                      padding: EdgeInsets.only(left: index == 1 ? height / 50 :height / 48.8),
                      child: Consumer<MenuModel>(
                          builder: (context, model, child) {
                            return Container(
                              child: ChoiceChip(
                                  label: Container(
                                    margin: EdgeInsets.all(height / 300),
                                    child: Row(
                                        children: [
                                          CircleAvatar(
                                              backgroundColor:  isGeneral
                                                  ? HexColor.fromHex(provider2.activities["general"][index - 1].color as String)
                                                  : HexColor.fromHex(specificActivities[index - 1].color),
                                              radius: 5
                                          ),
                                          Text(
                                              isGeneral
                                                  ? "  ${provider2.activities["general"][index - 1].name}"
                                                  : "  ${specificActivities[index - 1].name}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: height / 61
                                              )
                                          )
                                        ]
                                    ),
                                  ),
                                  backgroundColor: Color.fromRGBO(222, 222, 222, 1.0),
                                  selectedColor: Colors.white,
                                  selected: isGeneral ? index == model.selectedGeneralActivity : index == model.selectedActivity,
                                  onSelected: (selected) {
                                    if (selected) {
                                      if (isGeneral) {
                                        model.selectedGeneralActivity = index;
                                        model.selectedActivity = 1;
                                      } else {
                                        model.selectedActivity = index;
                                      }
                                    }
                                  }
                              ),
                            );
                          }
                      )
                  );
                }
            )
        );
      },
    );
  }
}

/// This class represents a custom duration slider contained in the second page of the menu

class DurationSlider extends StatefulWidget {

  /// Min and max values of the slider
  final int min, max;
  /// Color of the slider
  final Color color;
  /// Title of the slider
  final String title;
  /// Actions to perform after user finishes changing values
  final Function(double) onChange;

  const DurationSlider({
    required this.min,
    required this.max,
    required this.color,
    required this.title,
    required this.onChange
  });

  @override
  _DurationSliderState createState() => _DurationSliderState();
}

/// This class represents the state of the above widget

class _DurationSliderState extends State<DurationSlider> {

  /// Current value

  double _value = -1;

  @override
  Widget build(BuildContext context) {
    if (_value == -1) {
      final title = widget.title;
      if (title == AppLocalizations.of(context)!.focusSession) _value = Provider.of<TimerModel>(context, listen: false).selectedMinutes.roundToDouble();
      if (title == AppLocalizations.of(context)!.shortBreak) _value = 5.0;
      if (title == AppLocalizations.of(context)!.longBreak) _value = 15.0;
      if (title == AppLocalizations.of(context)!.repetitions) _value = 4;
    }
    return Container(
      width: width / 1.25,
      margin: EdgeInsets.only(bottom: height / 365),
      child: Column(
        children: [
          TitleMenuText(
            title: "${widget.title}: ${_value.toStringAsFixed(0)} ${widget.title == "Repetitions"
                ? AppLocalizations.of(context)!.times
                : AppLocalizations.of(context)!.min
            }",
            alignment: Alignment.center
          ),
          Slider(
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            value: _value,
            activeColor: widget.color,
            inactiveColor: Colors.grey,
            divisions: widget.max,
            label: "${_value.toStringAsFixed(0)}${widget.title == "Repetitions" ? "x" : "m"}",
            onChanged: (double value) {
              setState(() {
                this._value = value;
              });
            },
            onChangeEnd: (value) {
              widget.onChange(value);
            }
          )
        ]
      )
    );
  }
}

/// This class represents the base of a dialog with the app's style

class CustomDialogBase extends StatelessWidget {

  /// The icon at the top
  final Widget titleIcon;
  /// The body of the dialog
  final Widget body;

  const CustomDialogBase({
    required this.titleIcon,
    required this.body
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.only(bottom: 15),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(height / 24.5)),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(height / 24.5))
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: titleIcon
            )
          )
        ),
        body
      ]
    );
  }
}

/// This class represents the dialog that appears when the user wants to give up focusing

class GiveUpDialog extends StatelessWidget {

  const GiveUpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialogBase(
      titleIcon: Image.asset(
        "resources/images/general/dead-tree.png",
        height: height / 18,
      ),
      body: Column(
        children: [
        SizedBox(height: height / 30,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 20),
          child: Text(
              AppLocalizations.of(context)!.confirmCancelTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: height / 46,
              fontWeight: FontWeight.w600
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 52),
          child: Text(
              AppLocalizations.of(context)!.confirmCancelSub,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: height / 56,
              fontWeight: FontWeight.w400,
              color: Colors.black38
            )
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: "${AppLocalizations.of(context)!.cancel}",
                  color: Color.fromRGBO(210, 210, 210, 1.0),
                  onPressed: () {
                    Navigator.pop(context);
                  }
                  ),
                SizedBox(width: width / 15,),
                CustomButton(
                  text: "${AppLocalizations.of(context)!.giveUp}",
                  color: Colors.red,
                  onPressed: () {
                    stopTimer(context, true);
                    Navigator.of(context,rootNavigator: true).pop();
                  }
                )
              ]
          ),
        ),
        SizedBox(height: height / 150)
        ]
      )
    );
  }
}

/// This class represents the dialog that appears when the user wants to write down
/// what he did in the successful session

class SessionSummaryDialog extends StatelessWidget {

  const SessionSummaryDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return CustomDialogBase(
      titleIcon: Icon(
        Icons.drive_file_rename_outline,
        color: Colors.white,
        size: height / 20,
      ),
      body: Column(
        children: [
          SizedBox(height: height / 35,),
          Text(
              AppLocalizations.of(context)!.writeAchievements,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: height / 48.8,
              fontWeight: FontWeight.w600
            )
          ),
          SizedBox(height: height / 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: TextField(
              controller: controller,
              maxLines: 6,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(height / 36.0),
                  borderSide: BorderSide.none
                )
              )
            )
          ),
          CustomButton(
            text: " ${AppLocalizations.of(context)!.done} ",
            onPressed: () {
              Navigator.pop(context);
              timeline["timeline"][formatDate(DateTime.now())].first["text"] = controller.text;
              TIMELINE_FILE.write(jsonEncode(timeline));
            }
          )
        ]
      )
    );
  }
}

/// The reasons why the user could fail focusing

var reasons = (BuildContext context) => [
  AppLocalizations.of(context)!.failure1,
  AppLocalizations.of(context)!.failure2,
  AppLocalizations.of(context)!.failure3,
  AppLocalizations.of(context)!.failure4,
  AppLocalizations.of(context)!.failure5,
  AppLocalizations.of(context)!.failure6
];

/// Which reasons the user has selected

var reasonsSelected = [
  false,
  false,
  false,
  false,
  false,
  false
];

/// This class represents the dialog that appears when the user wants to understand
/// why he failed his focus session

class FailureReasonDialog extends StatelessWidget {

  const FailureReasonDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialogBase(
      titleIcon: Image.asset(
        "resources/images/general/dead-tree.png",
        height: height / 18,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height / 35,),
          Text(
            AppLocalizations.of(context)!.whyYouFailed,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: height / 49,
              fontWeight: FontWeight.w600
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
            child: Text(
                AppLocalizations.of(context)!.whyYouFailedSub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: height / 56,
                fontWeight: FontWeight.w400,
                color: Colors.black38
              )
            )
          ),
          ReasonCheckBox(index: 0),
          ReasonCheckBox(index: 1),
          ReasonCheckBox(index: 2),
          ReasonCheckBox(index: 3),
          ReasonCheckBox(index: 4),
          ReasonCheckBox(index: 5),
          SizedBox(height: height / 100),
          CustomButton(
            text: " ${AppLocalizations.of(context)!.select} ",
            textSize: height / 48,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context,rootNavigator: true).pop();
              bool added = true;
              for (int i = 0; i < 6; i++) {
                var a = reasonsSelected[i];
                if (a == true) {
                  timeline["timeline"][formatDate(DateTime.now())].first["text"] += "${added ? "for the following reasons: " : ""}${textA(context, i)?.toLowerCase()}${reasonsSelected.lastIndexOf(true) != i ? ", " : ""}";
                  added = false;
                  TIMELINE_FILE.write(jsonEncode(timeline));
                  /// Year
                  var b = timeJson["${DateTime.now().year}"]["reasons"];
                  b[i] += 1;
                  /// Month
                  var c = timeJson["${DateTime.now().year}"]["${DateTime.now().month}"]["reasons"];
                  c[i] += 1;
                  /// Day
                  var d = timeJson["${DateTime.now().year}"]["${DateTime.now().month}"]["${DateTime.now().day}"];
                  d[24 + i] += 1;
                }
              }
            }
          )
        ]
      )
    );
  }
}

String? textA(BuildContext context, int i) {
  final a = AppLocalizations.of(context);
  switch (i) {
    case 0:
      return a?.reason1;
    case 1:
      return a?.reason2;
    case 2:
      return a?.reason3;
    case 3:
      return a?.reason4;
    case 4:
      return a?.reason5;
    case 5:
      return a?.reason6;
  }
  return "";
}

/// This class represents the check box containing the reason why the user could
/// have failed focusing

class ReasonCheckBox extends StatefulWidget {

  final int index;

  const ReasonCheckBox({Key? key, required this.index}) : super(key: key);

  @override
  _ReasonCheckBoxState createState() => _ReasonCheckBoxState();
}

/// This class represents the state of the above widget

class _ReasonCheckBoxState extends State<ReasonCheckBox> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CheckboxListTile(
        dense: true,
          title: Text(
            reasons(context)[widget.index],
            style: TextStyle(
              fontSize: height / 56
            ),
          ),
          value: reasonsSelected[widget.index],
          onChanged: (bool? value) {
            setState(() {
              reasonsSelected[widget.index] = value!;
            });
          },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Theme.of(context).primaryColor
      )
    );
  }
}

class SavedPage extends StatelessWidget {

  const SavedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuModel>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Coming soon...",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: height / 52,
              color: Colors.white
            )
          ),
          SizedBox(height: provider.selectedPomodoro ? height / 10 : height / 6.5),
        ],
      ),
    );
  }
}

TextEditingController roomCodeController = TextEditingController();

class EnterRoomCodeDialog extends StatelessWidget {

  EnterRoomCodeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialogBase(
        titleIcon: Icon(
          Icons.vpn_key,
          color: Colors.white,
          size: height / 20,
        ),
        body: Column(
            children: [
              SizedBox(height: height / 35,),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                    AppLocalizations.of(context)!.enterKeyRoom,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: height / 48.8,
                        fontWeight: FontWeight.w600
                    )
                ),
              ),
              SizedBox(height: height / 100),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
                  child: UsernameForm(() {})
              )
            ]
        )
    );
  }
}

class UsernameForm extends StatefulWidget {
  final Function onSuccess;

  UsernameForm(this.onSuccess);

  @override
  _UsernameFormState createState() => _UsernameFormState(onSuccess);
}

class _UsernameFormState extends State<UsernameForm> {

  final _formKey = GlobalKey<FormState>();
  bool _usernameTaken = false;
  bool loading = false;
  final Function onSuccess;

  _UsernameFormState(this.onSuccess);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            validator: (value) {
              if (_usernameTaken) {
                return 'The key is not valid';
              }
              return null;
            },
            onSaved: (value) {
              _isValidKey(value!);
            },
            onChanged: (value) {
              _isValidKey(value);
            },
            controller: roomCodeController,
            maxLines: 1,
            cursorColor: Colors.black,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(height / 36.0),
                    borderSide: BorderSide.none
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CustomButton(
              text: AppLocalizations.of(context)!.enter,
              loading: loading,
              onPressed: () {
                setState(() {
                  loading = true;
                  _checkCode(roomCodeController.text, context);
                });
              }
            )
          ),
        ]
      ),
    );
  }

  void _isValidKey(String key) {
    if (key.length != 6) {
      setState(() {
        _usernameTaken = true;
      });
      return;
    }
    setState(() {
      _usernameTaken = false;
    });
  }

  /// poi salvo key della room in una variabile e appena apro la pagina, ho stream che ascolta quella key

  void _checkCode(String username, BuildContext context) async {
    if (username.isNotEmpty && username.length == 6) {
      if (Platform.isIOS) {
        flutterLocalNotificationsPlugin.show(
            1039492,
            AppLocalizations.of(context)!.featureAvailableSoon,
            AppLocalizations.of(context)!.featureAvailableSoonSub,
            platformChannelSpecifics
        );
        Future.delayed(Duration(seconds: 1), () {
          flutterLocalNotificationsPlugin.cancel(1039492);
        });
      }
      final email = getEmail(context);
      await sendPushMessage(
          body: jsonEncode({
            "email": email
          }),
          type: "join",
          topic: username
      );
      await FirebaseMessaging.instance.subscribeToTopic(username);
      Provider.of<SingleMultipleModel>(context, listen: false).createOrJoin = "Join";
      addCompanion(email!);
      Navigator.pop(context);
      key.value = username;
      _usernameTaken = false;
      loading = false;
      setState(() {
      });
    } else {
      setState(() async {
        _usernameTaken = true;
        loading = false;
      });
    }
  }
}

class CustomEndDrawer extends StatefulWidget {

  const CustomEndDrawer({Key? key}) : super(key: key);

  @override
  _CustomEndDrawerState createState() => _CustomEndDrawerState();
}

class _CustomEndDrawerState extends State<CustomEndDrawer> {

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width / 2,
        child: Drawer(
            child: Container(
                color: Theme.of(context).backgroundColor,
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: roomCompanions,
                  builder: (context, value, child) {
                    return Padding(
                      padding: EdgeInsets.only(left: width / 30),
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: value.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) return SizedBox(height: height / 14.6,);
                            final user = value.elementAt(index - 1);
                            return ListTile(
                              leading: CircleAvatar(
                                  backgroundColor: Color.fromRGBO(251, 246, 181, 1),
                                  radius: height / 36.6,
                                  child:  Icon(
                                    Icons.person_rounded,
                                    color: Color.fromRGBO(80, 163, 135, 1),
                                    size: height / 23,
                                  )
                              ),
                              title: Text(
                                "${AppLocalizations.of(context)!.user} $index",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height / 50,
                                ),
                              ),
                              subtitle: Text(
                                "$user\n",
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: height / 55
                                ),
                              ),
                            );
                          }
                      ),
                    );
                  },
                )
            )
        )
    );
  }
}
