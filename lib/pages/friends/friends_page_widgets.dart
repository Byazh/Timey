import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focus/models/models.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/utils/messages_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../utils/image_utils.dart';
import '../auth/login_page.dart';
import 'friends_page.dart';

/// creo un list tile per frriends, received e sent.
/// poi uso query builder di firebase per costruire lista e aggiornarla

class FriendTile extends StatelessWidget {

  final String name;
  final Future<String> image;
  final int success, failures;
  final int minutes;

   FriendTile({
    Key? key,
    required this.name,
    required this.image,
    required this.success,
    required this.failures,
     required this.minutes
  }) : super(key: key);

  Widget child = Container();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: width / 24, right: width / 24, bottom: height / 100),
      child: ListTile(
        leading: Container(
          width: height / 17.6,
          height: height / 13,
          child: Stack(
            children: [
              Align(
                alignment: king.value != name ? Alignment.center : Alignment.bottomCenter,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).backgroundColor,
                  radius: height / 36,
                  child: FutureBuilder(
                    future: image,
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      final data = snapshot.data;
                      if (data != null && data != "")
                        child = ClipOval(
                            child: Image.network(
                              data,
                                fit: BoxFit.cover,
                                height: height,
                                width: width
                            )
                        );
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: child
                      );
                    },
                  )
                ),
              ),
              if (king.value == name ) Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  "resources/images/general/crown.png",
                  height: height / 35
                ),
              )
            ],
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
              fontSize: height / 48,
          ),
        ),
        subtitle: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: height / 90,
              child: Container(
                  margin: EdgeInsets.all(2),
                  child: Image.asset("resources/images/general/tree.png")
              ),
            ),
            Text(
                "   $success    ",
              style: TextStyle(
                fontSize: height / 70
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.red,
              radius: height / 90,
              child: Container(
                  margin: EdgeInsets.all(2),
                  child: Image.asset("resources/images/general/dry-tree.png")
              ),
            ),
            Text(
                "   $failures",
              style: TextStyle(
                  fontSize: height / 70
              ),
            )
          ],
        ),
        trailing: ValueListenableBuilder<bool>(
          valueListenable: edit,
          builder: (context, value, child) {
            if (value && !name.contains("(You)")) {
              return GestureDetector(
                onTap: () async {
                  FirebaseFirestore.instance.collection("users").doc(getEmail(context)).update({"friends": FieldValue.arrayRemove([name])});
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.black54,
                  size: height / 36,
                ),
              );
            } else {
              if (Provider.of<SingleMultipleModel>(context, listen: false).createOrJoin == "") {
                return Text(
                  minutesToHours(minutes),
                  style: TextStyle(
                      fontSize: height / 52,
                      color: Colors.black54
                  ),
                );
              } else {
                return InviteButton(name);
              }
            }
          }
        )
      ),
    );
  }
}

class InviteButton extends StatefulWidget {

  final String name;

  const InviteButton(this.name);

  @override
  _InviteButtonState createState() => _InviteButtonState();
}

class _InviteButtonState extends State<InviteButton> {

  bool loading = false;

  bool invited = false;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: '${invited ? "${AppLocalizations.of(context)!.invited}": "${AppLocalizations.of(context)!.invite}"}',
      color: invited ? Colors.grey.withOpacity(0.75) : Color.fromRGBO(146, 209, 120, 1),
      loading: loading,
      onPressed: () async {
        setState(() {
          loading = true;
        });
        await sendPlantingInvite(context, topicEmail(widget.name.replaceAll(" (${AppLocalizations.of(context)!.you})", ""))).timeout(Duration(seconds: 5), onTimeout: () {
          showSnackBar(context, AppLocalizations.of(context)!.cantInviteFriend);
        }).whenComplete(() => invited = true);
        if (mounted) setState(() {
          loading = false;
        });
      },
    );
  }
}


class ReceivedTile extends StatelessWidget {

  final String name;
  final Future<String> image;
  final String email;

  ReceivedTile({
    Key? key,
    required this.name,
    required this.image, required this.email,
  }) : super(key: key);

  Widget child = Container();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: width / 24, right: width / 24, bottom: height / 100),
      child: ListTile(
          leading: CircleAvatar(
              backgroundColor: Theme.of(context).backgroundColor,
              radius: height / 36.6,
              child: FutureBuilder(
                future: image,
                builder: (context, AsyncSnapshot<String> snapshot) {
                  final data = snapshot.data;
                  if (data != null && data != "")
                    child = ClipOval(child: Image.network(data,
                        fit: BoxFit.cover,
                        height: height,
                        width: width));
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: child,
                  );
                },
              )
          ),
          title: Text(
            name,
            style: TextStyle(
                fontSize: height / 48.8
            ),
          ),
          subtitle: Text(
            email,
            maxLines: 1,
            style: TextStyle(
                fontSize: height / 54.8
            ),
          ),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  FirebaseFirestore.instance.collection("users").doc(getEmail(context)).update({
                    "received": FieldValue.arrayRemove([email]),
                    "friends": FieldValue.arrayUnion([email])});
                  FirebaseFirestore.instance.collection("users").doc(email).update({"friends": FieldValue.arrayUnion([getEmail(context)]), "sent": FieldValue.arrayRemove([getEmail(context)])});

                },
                child: Container(
                    width: height / 24.5,
                    height: height / 24.5,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 3,
                            color: Colors.green
                        )
                    ),
                    child: Icon(
                      Icons.done,
                      color: Colors.green,
                      size: height / 45
                    )
                ),
              ),
              SizedBox(width: width / 32,),
              GestureDetector(
                onTap: () async {
                  FirebaseFirestore.instance.collection("users").doc(getEmail(context)).update({"received": FieldValue.arrayRemove([email])});
                  FirebaseFirestore.instance.collection("users").doc(email).update({"sent": FieldValue.arrayRemove([getEmail(context)])});
                },
                child: Container(
                    width: height / 24.5,
                    height: height / 24.5,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 3,
                            color: Colors.red
                        )
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: height / 45,
                    )
                ),
              ),
            ],
          )
      ),
    );
  }
}

class SentTile extends StatelessWidget {

  final String name;
  final Future<String> image;
  final String email;

  SentTile({
    Key? key,
    required this.name,
    required this.image, required this.email,
  }) : super(key: key);

  Widget child = Container();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: width / 24, right: width / 24, bottom: height / 100),
      child: ListTile(
          leading: CircleAvatar(
              backgroundColor: Theme.of(context).backgroundColor,
              radius: height / 36.6,
              child: FutureBuilder(
                future: image,
                builder: (context, AsyncSnapshot<String> snapshot) {
                  final data = snapshot.data;
                  if (data != null && data != "")
                    child = ClipOval(child: Image.network(data,
                        fit: BoxFit.cover,
                        height: height,
                        width: width));
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: child,
                  );
                },
              )
          ),
          title: Text(
            name,
            style: TextStyle(
                fontSize: height / 48.8
            ),
          ),
          subtitle: Text(
            email,
            maxLines: 1,
            style: TextStyle(
                fontSize: height / 54.8
            ),
          ),
          trailing: GestureDetector(
            onTap: () async {
              FirebaseFirestore.instance.collection("users").doc(getEmail(context)).update({"sent": FieldValue.arrayRemove([email])});
              FirebaseFirestore.instance.collection("users").doc(email).update({"received": FieldValue.arrayRemove([getEmail(context)])});
            },
            child: Container(
              width: height / 24.4,
              height: height / 24.4,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 3,
                  color: Colors.black54
                )
              ),
              child: Icon(
                Icons.close,
                color: Colors.black54,
                size: height / 45,
              )
            ),
          )
      ),
    );
  }
}

TextEditingController friendController = TextEditingController();

class AddFriendDialog extends StatefulWidget {


  AddFriendDialog({Key? key}) : super(key: key);

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _globalKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _globalKey,
      child: CustomDialogBase(
          titleIcon: Icon(
            Icons.vpn_key,
            color: Colors.white,
            size: height / 20,
          ),
          body: Column(
              children: [
                SizedBox(height: height / 35,),
                Text(
                    AppLocalizations.of(context)!.enterEmailTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: height / 48.8,
                        fontWeight: FontWeight.w600
                    )
                ),
                SizedBox(height: height / 100),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                    child: CustomTextField(
                      controller: friendController,
                      wrong: (value ) {
                        return !value.contains("@") || !value.contains(".") || value == getEmail(context);
                      },
                      hintText: AppLocalizations.of(context)!.enterEmail,

                    )
                ),
                CustomButton(
                    text: AppLocalizations.of(context)!.add,
                    loading: loading,
                    onPressed: () {
                      if (_globalKey.currentState!.validate()) {
                        setState(() {
                          _globalKey.currentState!.save();
                          loading = true;
                          _checkCode();
                        });
                      }
                    }
                )
              ]
          )
      ),
    );
  }

  void _checkCode() async {
    if (_globalKey.currentState!.validate()) {
      final sender = FirebaseFirestore.instance.collection("users").doc(getEmail(context));
      final receiver = FirebaseFirestore.instance.collection("users").doc(friendController.text);
      sender.update({"sent": FieldValue.arrayUnion([friendController.text])});
      if ((await sender.get()).exists) {
        sender.update({"sent": FieldValue.arrayUnion([friendController.text])});
        receiver.update({"received": FieldValue.arrayUnion([getEmail(context)])});
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "The user doesn't exist"
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(height / 49))),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }
}

class UserAvatar extends StatelessWidget {

  final String image;
  final String firstLetter;
  const UserAvatar({Key? key, required this.image, required this.firstLetter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: image == "" ? Color.fromRGBO(112, 199, 120, 1.0) : Color.fromRGBO(255, 247, 140, 1.0),
        radius: height / 49,
        child: image == "" ? CircleAvatar(
          backgroundColor: Color.fromRGBO(251, 246, 181, 1.0),
          radius: height / 56,
          child: Text(
            firstLetter.toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: height / 56,
                color: Colors.black54
            ),
          ),
        ) : ClipOval(
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: image,
                fit: BoxFit.cover,
                height: height,
                width: width
            )
        )
    );
  }
}
