import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus/main.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:focus/pages/sounds/sounds_page_widgets.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:just_audio/just_audio.dart';

import '../../utils/coins_utilities.dart';
import '../../utils/dialog_utils.dart';

AudioPlayer player = AudioPlayer();

PageController soundsController = PageController();

class SoundsPage extends StatefulWidget {

  @override
  State<SoundsPage> createState() => _SoundsPageState();
}

class _SoundsPageState extends State<SoundsPage> {
  ValueNotifier _page = ValueNotifier(1);

  @override
  void dispose() {
   soundsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    soundsController = PageController();
    super.initState();
  }

  final colors = [
    Color.fromRGBO(239, 185, 34, 1),
    Color.fromRGBO(141, 205, 63, 1),
    Color.fromRGBO(77, 91, 217, 1.0),
    Color.fromRGBO(195, 139, 220, 1.0),
    Color.fromRGBO(224, 69, 69, 1.0),
    Color.fromRGBO(141, 205, 63, 1),
    Color.fromRGBO(53, 192, 217, 1.0),
  ];

  void playSound() async {
    await player.setAsset("resources/sounds/${sounds[_page.value - 1].toLowerCase()}.mp3");
    await player.setLoopMode(LoopMode.one);
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    soundsController = PageController();
    player.stop();
    playSound();
    return WillPopScope(
      onWillPop: () async {
        _page.value = 1;
        await player.stop();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(height / 13),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppBar(
                centerTitle: true,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
                backgroundColor: Colors.transparent,
                leading: GestureDetector(
                    child: Icon(
                        Icons.arrow_back,
                        color: Color.fromRGBO(63, 61, 86, 1),
                        size: height / 35
                    ),
                    onTap: () async {
                      await player.stop();
                      Navigator.pop(context);
                    }
                ),
                actions: [
                  CoinsWidget()
                ],
                title: ValueListenableBuilder(
                  valueListenable: _page,
                  builder: (context, value, child) {
                    return Text(
                      "${_page.value} ${AppLocalizations.of(context)!.ofTot} 7",
                      style: TextStyle(
                          color: Color.fromRGBO(63, 61, 86, 1),
                          fontSize: height / 48.8
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: PageView.builder(
            controller: soundsController,
          physics: BouncingScrollPhysics(),
          itemCount: 7,
          onPageChanged: (page) async {
            _page.value = page + 1;
            await player.stop();
            playSound();
            },
          itemBuilder: (context, index) {
            var name = sounds[index];
            final isUnlocked = soundsUnlocked.contains(name);
            return Padding(
              padding: EdgeInsets.only(left: width / 14.4, right: width / 14.4, ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 1,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Opacity(
                        opacity: index != 0 ? 1 : 0,
                        child: GestureDetector(
                          child: Icon(
                            Icons.arrow_left,
                            size: height / 20.91,
                            color: Color.fromRGBO(63, 61, 86, 1),
                          ),
                          onTap: () {
                            soundsController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
                          },
                        ),
                      ),
                      Text(
                        reflectionUtils(name, context),
                        style: TextStyle(
                            fontSize: height / 24.4,
                            color: Color.fromRGBO(63, 61, 86, 1),
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      Opacity(
                        opacity: index != 6 ? 1 : 0,
                        child: GestureDetector(
                          child: Icon(
                            Icons.arrow_right,
                            size: height / 20.91,
                            color: Color.fromRGBO(63, 61, 86, 1),
                          ),
                          onTap: () {
                            soundsController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
                          },
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: height / 1.5,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: height / 3.8,
                          child: Container(
                            color: colors[index].withOpacity(0.8),
                            height: height / 2,
                            width: width,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: height / 7.32),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: width / 7.2),
                                    child: Column(
                                      children: [
                                        Text(
                                          "${soundDescriptions(context)[index]}",
                                          style: TextStyle(
                                              color: Color.fromRGBO(63, 61, 86, 1).withOpacity(0.7),
                                            fontSize: height / 52
                                          ),
                                        ),
                                        SizedBox(height: height / 25,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.monetization_on, color: Color.fromRGBO(
                                                    255, 233, 0, 1.0), size: height / 30,),
                                                Text(
                                                  "   ${soundPrices[index]}",
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(63, 61, 86, 1).withOpacity(0.7),
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: height / 48.8
                                                  ),
                                                )
                                              ],
                                            ),
                                            CustomButton(
                                                text: "   ${isUnlocked ? AppLocalizations.of(context)!.unlocked : AppLocalizations.of(context)!.unlock}   ",
                                                color: isUnlocked ? Colors.grey.withOpacity(0.6) : Color.fromRGBO(161, 228, 163, 0.8),
                                                onPressed: (){
                                                  if (isUnlocked) return;
                                                  if (coins >= soundPrices[index]) {
                                                    removeCoins(soundPrices[index]);
                                                    soundsUnlocked.add(sounds[index]);
                                                    saveSound(sounds[index], context);
                                                    setState(() {});
                                                  } else {
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
                                                                  padding: EdgeInsets.only(left: width / 24, right: width / 24, top: height / 244, bottom: height / 36.5),
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
                                                                    color: Colors.grey.withOpacity(0.6),
                                                                    textSize: height / 49,
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                    }),
                                                              ],
                                                            )
                                                        ),
                                                        duration: Duration(milliseconds: 500)
                                                    );
                                                  }
                                                })
                                          ],
                                        ),
                                        SizedBox(height: height / 25)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: height / 5,
                          child: ClipOval(
                            child: Container(
                              width: width - 50,
                              height: height / 9,
                              decoration: BoxDecoration(
                                color: colors[index],
                                boxShadow: [
                                  /*BoxShadow(
                                    color: Colors.black,
                                    spreadRadius: 10,
                                    blurRadius: 1
                                  )*/
                                ]
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: Image.asset(
                            "resources/images/sounds/${name.toLowerCase()}.png",
                            height: height / 3.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ),
            );
          }
        )
      ),
    );
  }
}

final sounds = [
  "rain",
  "cafe",
  "forest",
  "city",
  "sea",
  "chill",
  "classical"
];

String reflectionUtils(String sound, BuildContext context) {
  switch (sound) {
    case "rain":
      return AppLocalizations.of(context)!.rain.toLowerCase();
    case "cafe":
      return AppLocalizations.of(context)!.cafe.toLowerCase();
    case "forest":
      return AppLocalizations.of(context)!.forest.toLowerCase();
    case "city":
      return AppLocalizations.of(context)!.city.toLowerCase();
    case "sea":
      return AppLocalizations.of(context)!.sea.toLowerCase();
    case "chill":
      return AppLocalizations.of(context)!.chill.toLowerCase();
    case "classical":
      return AppLocalizations.of(context)!.classical.toLowerCase();
  }
  return sound;
}
