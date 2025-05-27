import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/scan/stamp_redemption.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ScanCache {
  Future<void> redeem(context) async {
    const storage = FlutterSecureStorage();
    final scanCache = await storage.read(key: "scans");
    if (scanCache == null) {
      return;
    }
    var scans = jsonDecode(scanCache);
    if (scans.isEmpty) {
      return;
    }
    var remainingScans = [];
    var failedResults = 0;
    for (var scan in scans) {
      var redemptionResult = await StampRedemption(
              stamp: scan["stamp"], picc: scan["picc"], cmac: scan["cmac"])
          .redeem(context);
      if (redemptionResult == 0) {
        remainingScans.add(scan);
      } else if (redemptionResult == 1) {
        failedResults++;
      }
    }
    await processRedemptionResult(context, remainingScans, failedResults);
  }

  Future<void> processRedemptionResult(
      context, remainingScans, failedResults) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "scans", value: jsonEncode(remainingScans));
    if (remainingScans.isEmpty) {
      Alert(
        description: "product.scan.cache.redemption.successful",
        type: AlertType.success,
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
    } else if (failedResults > 0) {
      Alert(
        description: "product.scan.cache.redemption.failed",
        type: AlertType.error,
      ).show(context);
    }
  }
}
