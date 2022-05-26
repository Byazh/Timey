
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:focus/pages/home/home_page_widgets.dart';
import 'package:focus/utils/dialog_utils.dart';
import 'package:focus/utils/multi_utils.dart';
import 'package:focus/utils/notifications_utils.dart';
import 'package:focus/utils/stripe_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';

class PaymentPage extends StatelessWidget {

  final bool info;

  late stripe.PaymentMethod? method;

   PaymentPage({Key? key, this.info = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
          physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(height / 6), bottomRight: Radius.circular(height / 6)
                )
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: true,
            leading: GestureDetector(
                child: Icon(
                    Icons.arrow_back,
                    color: Color.fromRGBO(44, 106, 85, 1.0),
                    size: height / 35
                ),
                onTap: () {
                  Navigator.pop(context);
                }
            ),
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: height / 9,
            collapsedHeight: height / 10,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              title: Text(
                AppLocalizations.of(context)!.appPremium,
                style: TextStyle(
                    color: Color.fromRGBO(44, 106, 85, 1.0),
                    fontSize: height / 45,
                    fontWeight: FontWeight.w600
                ),
              )
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(height / 50),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                        margin: EdgeInsets.only(left: width / 15, right: width / 15, bottom: height / 30),
                        child: Stack(
                            children: [
                              Column(
                                  children: [
                                    Text(
                                        "\n${AppLocalizations.of(context)!.priceOfCoffee}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color.fromRGBO(44, 106, 85, 1.0),
                                            fontSize: height / 38,
                                            fontWeight: FontWeight.w600
                                        )
                                    ),
                                    Text(
                                        AppLocalizations.of(context)!.premiumPar1,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                            color: Color.fromRGBO(44, 106, 85, 1.0),
                                            fontSize: height / 50,
                                            fontWeight: FontWeight.w400
                                        )
                                    ),
                                    Text(
                                        AppLocalizations.of(context)!.premiumPar2,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                            color: Color.fromRGBO(44, 106, 85, 1.0),
                                            fontSize: height / 50,
                                            fontWeight: FontWeight.w400
                                        )
                                    ),
                                    Text(
                                        "${AppLocalizations.of(context)!.premiumPar3 + (info ? "" : "${AppLocalizations.of(context)!.premiumPar4}\n\n\n\n")}",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                            color: Color.fromRGBO(44, 106, 85, 1.0),
                                            fontSize: height / 50,
                                            fontWeight: FontWeight.w400
                                        )
                                    )
                                  ]
                              )
                            ]
                        )
                    );
                  },
                childCount: 1,
              ),
            )
          ),
        ],
      ),
      floatingActionButton: info ? Container() : BuyButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

void youAreNowPremium(BuildContext context) async  {
  await FirebaseFirestore.instance.collection("users").doc(getEmail(context)).update(
    {
      "premium": true
    }
  );
  showFadingDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CustomDialogBase(
          titleIcon: Icon(
              Icons.done,
              color: Colors.white,
              size: height / 25
          ),
          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      left: width / 50,
                      right: width / 50,
                      top: height / 24.5,
                      bottom: height / 90
                  ),
                  child: Text(
                      AppLocalizations.of(context)!.successfulPayment,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: height / 46,
                          fontWeight: FontWeight.w600
                      )
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: width / 26,
                      right: width / 26,
                      top: height / 250,
                      bottom: height / 36
                  ),
                  child: Text(
                      AppLocalizations.of(context)!.successfulPaymentSub,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: height / 52,
                          fontWeight: FontWeight.w400
                      )
                  )
              )
            ],
          ),
        );
      },
      duration: Duration(milliseconds: 500)
  );
}

class BuyButton extends StatefulWidget {
  const BuyButton({Key? key}) : super(key: key);

  @override
  State<BuyButton> createState() => _BuyButtonState();
}

class _BuyButtonState extends State<BuyButton> {

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          margin: EdgeInsets.only(bottom: height / 75),
          width: width / 2.75,
          height: height / 13,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 20),
              color: Color.fromRGBO(63, 147, 119, 1.0)
          ),
          child: Center(
            child: loading ? CupertinoActivityIndicator() : Text(
              AppLocalizations.of(context)!.buy,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: height / 46
              ),
            ),
          ),
        ),
        onTap: () async {
          setState(() {
            loading = true;
          });
          final intent = await createPaymentIntent(
              method: "-1",
              currency: "EUR",
              amount: 299
          );
          setState(() {
            loading = false;
          });
          if (intent == null) return;
          final clientSecret = intent['client_secret'];
          await stripe.Stripe.instance.initPaymentSheet(paymentSheetParameters:
          stripe.SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,
              applePay: true,
              googlePay: true,
              merchantCountryCode: "IT",
              merchantDisplayName: "Francesco Sottero",
              testEnv: false,
              customerId: getEmail(context)
          )
          );
          try {
            await stripe.Stripe.instance.presentPaymentSheet();
            youAreNowPremium(context);
          } catch (e) {
            showSnackBar(context, "Contact support: ${e.toString().substring(0, 30)}");
          }
        }
    );
  }
}
