import 'package:dulno/alert/alert.dart';
import 'package:flutter/cupertino.dart';

class ConnectionAlert {
  ConnectionAlert();

  show(context) {
    Alert(
      description: "connection.failed",
      icon: CupertinoIcons.exclamationmark_triangle,
    ).show(context);
  }
}
