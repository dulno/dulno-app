import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/profile/profile_logout.dart';
import 'package:flutter/cupertino.dart';

class RequestReset {
  reset(context) async {
    await ProfileLogout().reset(context);
    Alert(
      description: "connection.logout",
      icon: CupertinoIcons.exclamationmark_triangle,
      callback: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    ).show(context);
  }
}