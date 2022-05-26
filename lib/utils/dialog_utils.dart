import 'package:flutter/cupertino.dart';

/// Shows an fading animated dialog

void showFadingDialog({
  required BuildContext context,
  required WidgetBuilder builder,
  required Duration duration,
  Curve curve = Curves.linear,
  bool barrierDismissible = false
}) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Builder(builder: builder);
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: "",
    transitionDuration: duration,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    }
  );
}

String dialogCode = "yUKQhFfJPZ-nAiM4fwSWNAseto2Ak6N";