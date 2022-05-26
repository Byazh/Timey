import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:focus/pages/plants/plants_page_widgets.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:focus/utils/multi_utils.dart';

import '../../main.dart';
import '../../utils/coins_utilities.dart';

 PageController plantController = PageController();

class PlantsPage extends StatefulWidget {

  PlantsPage({Key? key}) : super(key: key);

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  ValueNotifier _page = ValueNotifier(1);

  @override
  void dispose() {
    plantController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    plantController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    plantController = PageController();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height / 13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
              centerTitle: true,
              leading: GestureDetector(
                  child: Icon(
                      Icons.arrow_back,
                      color: Color.fromRGBO(146, 91, 43, 1),
                      size: height / 35
                  ),
                  onTap: () {
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
                    "$value ${AppLocalizations.of(context)!.ofTot} 6",
                    style: TextStyle(
                        color: Color.fromRGBO(146, 91, 43, 1),
                        fontSize: height / 48.8
                    ),
                  );
                },
              )
            ),
          ],
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (a) {
          a.disallowIndicator();
          return true;
        },
        child: PageView.builder(
          controller: plantController,
          itemCount: 6,
          onPageChanged: (page) async {
            _page.value = page + 1;
          },
          itemBuilder: (context, index) {
            final isUnlocked = plantsUnlocked.contains(plantNames[index]);
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Opacity(
                      opacity: index != 0 ? 1 : 0,
                      child: GestureDetector(
                        child: Icon(
                          Icons.arrow_left,
                          size: height / 20.9,
                          color: Color.fromRGBO(146, 91, 43, 1),
                        ),
                        onTap: () {
                          plantController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
                        },
                      ),
                    ),
                    Text(
                      plantAppearanceNames(context)[index],
                      style: TextStyle(
                          fontSize: height / 20.9,
                          color: Color.fromRGBO(146, 91, 43, 1),
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    Opacity(
                      opacity: index != 5 ? 1 : 0,
                      child: GestureDetector(
                        child: Icon(
                          Icons.arrow_right,
                          size: height / 20.9,
                          color: Color.fromRGBO(146, 91, 43, 1),
                        ),
                        onTap: () {
                          plantController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: height / 6),
                Image.asset(
                  "resources/images/plants/$index.png",
                  height: height / 6.5,
                ),
                Container(
                  height: height / 2.6,
                  color: Color.fromRGBO(146, 91, 43, 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 10, vertical: height / 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          plantsDescriptions(context)[index],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: height / 45.75
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.monetization_on, color: Colors.yellow, size: 25,),
                                Text(
                                  "   ${plantsPrices[index]}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: height / 40.66
                                  ),
                                )
                              ],
                            ),
                            CustomButton(
                                text: "   ${isUnlocked ? AppLocalizations.of(context)!.unlocked :AppLocalizations.of(context)!.unlock}   ",
                                color: isUnlocked ? Colors.grey : Color.fromRGBO(161, 228, 163, 0.8),
                                onPressed: () async {
                                  if (isUnlocked) return;
                                  if (coins >= plantsPrices[index]) {
                                    removeCoins(plantsPrices[index]);
                                    plantsUnlocked.add(plantNames[index]);
                                    savePlant(plantNames[index], context);
                                    setState(() {

                                    });
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
                                                 padding: EdgeInsets.only(left: width / 45.0, right: width / 45, top: height / 24.5, bottom: height / 146),
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
                                                   color: Colors.grey.withOpacity(0.5),
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
                                },
                              textSize: height / 45.75,
                                )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ]
            );
          },
        ),
      )
    );
  }
}
