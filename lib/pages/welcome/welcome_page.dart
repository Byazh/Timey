import 'package:flutter/material.dart';

import 'package:focus/pages/welcome/welcome_page_widgets.dart';

/// This controller handles the welcome page

final controller = PageController();

/// This class represents the page that appears when the user launches the app
/// for the first time ever

class WelcomePage extends StatelessWidget {

  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: BouncingScrollPhysics(),
        controller: controller,
        itemCount: 5,
        itemBuilder: (context, index) {
          return WelcomeSlide(index);
        }
      )
    );
  }
}