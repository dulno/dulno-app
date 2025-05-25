import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/coupon/coupon_redemption.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CouponCache {
  Future<void> redeem(context) async {
    const storage = FlutterSecureStorage();
    final redemptionCache = await storage.read(key: "redemptionCache");
    if (redemptionCache == null) {
      return;
    }
    var redemptionList = jsonDecode(redemptionCache);
    if (redemptionList.isEmpty) {
      return;
    }
    var remainingRedemptionList = [];
    var failedResults = 0;
    for (var redemption in redemptionList) {
      var redemptionResult = await CouponRedemption(
        coupon: redemption["coupon"],
        stamp: redemption["stamp"],
        picc: redemption["picc"],
        cmac: redemption["cmac"],
      ).redeem(context);
      if (redemptionResult == 0) {
        remainingRedemptionList.add(redemption);
      } else if (redemptionResult == 1) {
        failedResults++;
      }
    }
    await processRedemptionResult(
        context, remainingRedemptionList, failedResults);
  }

  Future<void> processRedemptionResult(
      context, remainingRedemptionList, failedResults) async {
    const storage = FlutterSecureStorage();
    await storage.write(
        key: "redemptionCache", value: jsonEncode(remainingRedemptionList));
    if (remainingRedemptionList.isEmpty) {
      Alert(
        description: "product.coupon.redemption.successful",
        icon: CupertinoIcons.check_mark_circled,
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
        description: "product.coupon.redemption.failed",
        icon: CupertinoIcons.exclamationmark_triangle,
      ).show(context);
    }
  }
}
