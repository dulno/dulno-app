import 'dart:io';

import 'package:dulno/product/scan/android_scan_popup.dart';
import 'package:dulno/product/scan/ios_scan_popup.dart';
import 'package:flutter/material.dart';

class ScanPopup {
  Function callback;
  Function currentPageIndex;

  ScanPopup({required this.callback, required this.currentPageIndex});

  show(BuildContext context, Key? key) {
    if (Platform.isAndroid) {
      _showAndroid(context, key);
    } else if (Platform.isIOS) {
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
            Navigator.of(context).pop();
          },
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.translucent,
              child: AndroidScanPopupContent(
                key: key,
                callback: callback,
                currentPageIndex: currentPageIndex,
              ),
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
          child: IOSScanPopupContent(
            key: key,
            callback: callback,
            currentPageIndex: currentPageIndex,
          ),
        );
      },
    );
  }
}
