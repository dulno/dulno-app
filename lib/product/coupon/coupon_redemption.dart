import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CouponRedemption {
  final String coupon;
  final String stamp;
  final String picc;
  final String cmac;
  late Map<String, dynamic> responseBody;

  CouponRedemption({
    required this.coupon,
    required this.stamp,
    required this.picc,
    required this.cmac,
  });

  Future<int> redeem(context) async {
    const storage = FlutterSecureStorage();
    var body = <String, Object>{
      "coupon": coupon,
      "stamp": stamp,
      "picc": picc,
      "cmac": cmac
    };
    final couponCache = await storage.read(key: "coupons");
    var coupons = (couponCache == null ? [] : jsonDecode(couponCache))
        .map((coupon) => coupon["redeemableId"])
        .toList();
    body["coupons"] = coupons;
    final partnerCache = await storage.read(key: "partners");
    var partners = partnerCache == null ? [] : jsonDecode(partnerCache);
    body["partners"] = partners;
    var response = await Request.post(url: "/user/coupon/redeem/", body: body)
        .send(context);
    if (response == null || response.statusCode == 409) {
      return 0;
    }
    responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return 1;
    }
    await updateCouponCache();
    return 2;
  }

  Future<void> updateCouponCache() async {
    const storage = FlutterSecureStorage();
    final couponCache = await storage.read(key: "coupons");
    var coupons = couponCache == null ? [] : jsonDecode(couponCache);
    coupons.removeWhere((entry) => entry["redeemableId"] == coupon);
    await storage.write(key: "coupons", value: jsonEncode(coupons));
  }

  Future<bool> redeemProcessed(context) async {
    var redemptionResult = await redeem(context);
    if (redemptionResult == 0) {
      processRedemptionUnconnected(context);
      return false;
    }
    if (redemptionResult == 1) {
      Navigator.pop(context);
      displayScanError(context, responseBody["error"]);
      return false;
    }
    return true;
  }

  Future<void> processRedemptionUnconnected(context) async {
    var redemption = <String, Object>{
      "coupon": coupon,
      "stamp": stamp,
      "picc": picc,
      "cmac": cmac,
    };
    const storage = FlutterSecureStorage();
    final redemptionCache = await storage.read(key: "redemptionCache");
    var redemptionList = redemptionCache == null ? [] : jsonDecode(redemptionCache);
    redemptionList.add(redemption);
    await storage.write(key: "redemptionCache", value: jsonEncode(redemptionList));
    Navigator.pop(context);
    Alert(
      description: "product.coupon.redemption.connection.cache",
      icon: CupertinoIcons.antenna_radiowaves_left_right,
    ).show(context);
  }

  void displayScanError(context, error) {
    var description = "";
    if (error == 1000) {
      description = "product.coupon.redemption.error.stamp.existence";
    } else if (error == 1001) {
      description = "product.coupon.redemption.error.stamp.state";
    } else if (error == 1002 || error == 1003) {
      description = "product.coupon.redemption.error.scan.validation";
    } else if (error == 1004) {
      description = "product.coupon.redemption.error.already.scanned";
    } else if (error == 1005) {
      description = "product.coupon.redemption.error.coupon.existence";
    } else if (error == 1006) {
      description = "product.coupon.redemption.error.stamp.partner";
    } else if (error == 1007) {
      description = "product.coupon.redemption.error.expired";
    }
    Alert(
      description: description,
      icon: CupertinoIcons.exclamationmark_triangle,
    ).show(context);
    return;
  }
}
