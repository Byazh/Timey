import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String? email(BuildContext context){
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.email == null) {
    Navigator.pushNamed(context, "/auth");
  }
  return user?.email;
}