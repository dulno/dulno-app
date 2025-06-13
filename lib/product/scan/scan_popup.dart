import 'dart:io';

import 'package:dulno/product/scan/android_scan_popup.dart';
import 'package:dulno/product/scan/ios_scan_popup.dart';
import 'package:dulno/product/scan/scan_cooldown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScanPopup {
  Function callback;

  ScanPopup({required this.callback});

  show(BuildContext context, Key? key) {
    ScanCooldown().reset();
    if (!kIsWeb && Platform.isAndroid) {
      _showAndroid(context, key);
    } else if (!kIsWeb && Platform.isIOS) {
      _showIOS(context, key);
    }
  }

  _showAndroid(BuildContext context, Key? key) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.translucent,
              child: AndroidScanPopupContent(key: key, callback: callback),
            ),
          ),
        );
      },
    );
  }

  _showIOS(BuildContext context, Key? key) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.topCenter,
          child: IOSScanPopupContent(key: key, callback: callback),
        );
      },
    );
  }
}
