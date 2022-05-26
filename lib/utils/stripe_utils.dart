import 'dart:convert';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

Future<PaymentMethod> createPaymentMethodFromNonNative(String token) async {
  return Stripe.instance.createPaymentMethod(
      PaymentMethodParams.cardFromToken(token: token)
  );
}

Future<Map<String, dynamic>?> createPaymentIntent(
    {required String method,
      required int amount,
      required String currency
    }) async {
  final appCheckToken = await FirebaseAppCheck.instance.getToken();
  const url = "https://us-central1-focus-6b0cb.cloudfunctions.net/StripePI";

  final response = await http.get(
      Uri.parse("$url?amount=$amount&currency=$currency&paym=${method}"),
    headers: {
        "X-Firebase-AppCheck": appCheckToken.toString()
    }
  );
  if (response.body != "") {
    final json = jsonDecode(response.body);
    final status = json["paymentIntent"]["status"];
    final account = json["stripeAccount"];
    // Ok
    if (status == "succeeded" || status == "requires_payment_method") {
      if (account != null) Stripe.stripeAccountId = account;
      return json["paymentIntent"];
    // Needs to authenticate
    } else if (status == "processing") {
    // Failed
    } else {

    }
  }
  return null;
}

