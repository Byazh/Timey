import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus/pages/friends/friends_page_widgets.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';

ValueNotifier<bool> edit = ValueNotifier(false);

ValueNotifier<String> king = ValueNotifier("");

class GroupsPage extends StatefulWidget {

  const GroupsPage({Key? key}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {

  ValueNotifier<String> _selectedValue = ValueNotifier("0");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(80, 163, 135, 1.0),
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height / 6.75),
        child: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(80, 163, 135, 1.0),
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(top: height / 60),
            child: GestureDetector(
                child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: height / 34.8
                ),
                onTap: () {
                  Navigator.pop(context);
                }
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: height / 60),
            child: Text(
                "Friends",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: height / 52.3,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500
                )
            ),
          ),
          actions: [
            _selectedValue.value == "0" ? Padding(
              padding: EdgeInsets.only(right: width / 32),
              child: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: edit,
                  builder: (context, value, child) {
                      if (value) {
                        return GestureDetector(
                          onTap: () {
                            edit.value = false;
                          },
                          child: Icon(
                            Icons.done,
                            color: Colors.white,
                            size: height / 36.6,
                          ),
                        );
                      } else if (key.value == ""){
                        return GestureDetector(
                          onTap: () {
                            edit.value = true;
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: width / 32),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: height / 36.6,
                            ),
                          )
                        );
                      } else {
                        return Container();
                      }
                    }
                ),
              )
            ) : Container()
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(height / 13),
            child: Container(
              margin: EdgeInsets.only(top: height / 365),
              child: ValueListenableBuilder(
                valueListenable: _selectedValue,
                builder: (context, value, child) {
                  return MaterialSegmentedControl(
                      onSegmentChosen: (String value) {
                        _selectedValue.value = value;
                      },
                      selectionIndex: _selectedValue.value,
                      selectedColor: Theme.of(context).primaryColor,
                      borderColor: Colors.transparent,
                      unselectedColor: Color.fromRGBO(64, 133, 110, 1),
                      verticalOffset: height / 100,
                      horizontalPadding: EdgeInsets.only(bottom: width / 26),
                      children: {
                        "0": Text(
                          "       ${AppLocalizations.of(context)!.friends}       ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: height / 58.5
                          ),
                        ),
                        "1": Text(
                          "      ${AppLocalizations.of(context)!.received}      ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: height / 58.5
                          ),
                        ),
                        "2": Text(
                          "      ${AppLocalizations.of(context)!.sent}      ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: height / 58.5
                          ),
                        )
                      }
                  );
                },
              )
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(height / 45),
        width: height / 8.13,
        height: height / 8.13,
        child: FloatingActionButton(
          onPressed: () {
            showFadingDialog(context: context, builder: (context) {
              return AddFriendDialog();
            },
            duration: Duration(milliseconds: 350),
              barrierDismissible: true
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: height / 29
          ),
          backgroundColor: Theme.of(context).backgroundColor
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        width: width,
        margin: EdgeInsets.only(top: height / 73.2),
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(height / 21), topRight: Radius.circular(height / 21))
        ),
        child: StreamBuilder(
          stream: getFriends(context),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.black54,
                        size: height / 35,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: width / 10),
                        child: Text(
                            AppLocalizations.of(context)!.noFriendsError
                        ),
                      )
                    ],
                  ),
                );
              case ConnectionState.waiting:
                return Center(child: CupertinoActivityIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
               final json = snapshot.data;
               if (json == null) {
                 FirebaseAuth.instance.currentUser!.reload().then((a) {
                   if (FirebaseAuth.instance.currentUser == null) {
                     Future.delayed(Duration(milliseconds: 100), () => Navigator.pushReplacementNamed(context, "/auth"));
                     flutterLocalNotificationsPlugin.show(
                         1111,
                         AppLocalizations.of(context)!.errorWithAccount,
                         AppLocalizations.of(context)!.errorWithAccountSub,
                         platformChannelSpecifics
                     );
                   }
                 });
                 return Center(
                   child: Column(
                     children: [
                       Icon(
                         Icons.error,
                         color: Colors.black54,
                         size: height / 35,
                       ),
                       Container(
                         margin: EdgeInsets.symmetric(horizontal: width / 10),
                         child: Text(
                             AppLocalizations.of(context)!.noFriendsError
                         ),
                       )
                     ],
                   ),
                 );
               }
               return ValueListenableBuilder(
                 valueListenable: _selectedValue,
                 builder: (context, value, child) {
                   return FutureBuilder(
                       future: () {
                         if (json.get("friends") == null) return Future.value(List.empty());
                         if (_selectedValue.value == "0")
                           return getFriendTiles(json["friends"]);
                         if (_selectedValue.value == "1")
                           return getReceivedList(json["received"]);
                         if (_selectedValue.value == "2")
                           return getSentList(json["sent"]);
                         else
                           return Future.value(List.empty());
                       }(),
                       builder: (context, AsyncSnapshot<List> snapshot) {
                         if (snapshot.hasData) {
                           if (snapshot.data?.length == 0) {
                             String text() {
                               switch (_selectedValue.value) {
                                 case "0":
                                   return "";
                                 case "1":
                                   return AppLocalizations.of(context)!.noPendingReceived;
                                 case "2":
                                   return AppLocalizations.of(context)!.noPendingSent;
                               }
                               return AppLocalizations.of(context)!.noFriendsError;
                             }
                             final a = text();
                             if (a == "") return Center(child: CupertinoActivityIndicator());
                             return Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Icon(
                                     Icons.people_alt_rounded,
                                     size: height / 14.6,
                                     color: Colors.black45,
                                   ),
                                   SizedBox(height: height / 73),
                                   Text(
                                     text(),
                                     textAlign: TextAlign.center,
                                     style: TextStyle(
                                         fontSize: height / 50,
                                         color: Colors.black45
                                     ),
                                   ),
                                   SizedBox(height: height / 12)
                                 ]
                             );
                           }
                           return ListView(
                             children: [
                               SizedBox(height: height / 45),
                               ...?snapshot.data
                             ],
                           );
                         }
                         return Center(child: CupertinoActivityIndicator());
                       }
                   );
                 },
               );
            }
            }
        )
      ),
    );
  }

  List<Map<String, dynamic>?> friendsCache = [];

  Stream<DocumentSnapshot> getFriends(BuildContext context) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(getEmail(context))
        .snapshots();
  }

  Future<List<FriendTile>> getFriendTiles(List friends) async {
    await Future.delayed(Duration(milliseconds: 100));
    List<FriendTile> tiles = [];
    friends.add(getEmail(context));
    final reversed = List.of(friends.reversed);
    for (String friend in reversed) {
      var user;
      var exists;
      friendsCache.forEach((element) {
        if (element != null && element.containsValue(friend)) {
          user = element;
          exists = true;
        }
      });
      if (user == null) {
        var request = (await FirebaseFirestore.instance.collection("users").doc(friend).get());
        exists = request.exists;
        user = request.data();
        friendsCache.add(user);
      }
      if (exists) {
        tiles.add(FriendTile(
          name: reversed.indexOf(friend) == 0 ? "(${AppLocalizations.of(context)!.you}) $friend" : friend,
          image: Future.value(user["image"]),
          success: user["success"],
          failures: user["failures"],
          minutes: user["minutes"],
          ));
        }
      }
    final you = tiles[0];
    tiles.sort((a, b) {
      return a.minutes - b.minutes;
    });
    king.value = tiles[0].name;
    tiles.remove(you);
    tiles.insert(0, you);
    return tiles;
    }
  }

List<Map<String, dynamic>?> receivedCache = [];

  Future<List> getReceivedList(List friends) async {
    await Future.delayed(Duration(milliseconds: 250));
    List<ReceivedTile> tiles = [];
    for (String friend in friends) {
      var user;
      var exists;
      receivedCache.forEach((element) {
        if (element != null && element.containsValue(friend)) {
          user = element;
          exists = true;
        }
      });
      if (user == null) {
        var request = (await FirebaseFirestore.instance.collection("users").doc(friend).get());
        exists = request.exists;
        user = request.data();
        receivedCache.add(user);
      }
      if (exists) {
        tiles.add(ReceivedTile(
          name: user["username"],
          image: Future.value(user["image"]),
          email: friend,
        ));
      }
    }
    return tiles;
  }

   List<Map<String, dynamic>?> sentCache = [];

  Future<List> getSentList(List friends) async {
    await Future.delayed(Duration(milliseconds: 250));
    List<SentTile> tiles = [];
    for (String friend in friends) {
      var user;
      var exists;
      sentCache.forEach((element) {
        if (element != null && element.containsValue(friend)) {
          user = element;
          exists = true;
        }
      });
      if (user == null) {
        var request = (await FirebaseFirestore.instance.collection("users").doc(friend).get());
        exists = request.exists;
        user = request.data();
        sentCache.add(user);
      }
      if (exists) {
        tiles.add(SentTile(
          name: user["username"],
          image: Future.value(user["image"]),
          email: friend,
        ));
      }
    }
    return tiles;
  }
