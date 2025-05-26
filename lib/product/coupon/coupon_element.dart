import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/alert/connection_alert.dart';
import 'package:dulno/alert/loader_alert.dart';
import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/coupon/coupon_expiration.dart';
import 'package:dulno/product/coupon/coupon_logo.dart';
import 'package:dulno/product/coupon/coupon_redemption.dart';
import 'package:dulno/product/coupon/coupon_redemption_popup.dart';
import 'package:dulno/product/scan/scan_cooldown.dart';
import 'package:dulno/product/scan/scan_popup.dart';
import 'package:dulno/request/request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum CouponElementState { collectable, redeemable }

class CouponElement extends StatefulWidget {
  final bool isLoading;
  final Map<String, dynamic> content;
  final CouponElementState state;
  final bool unusable;

  const CouponElement({
    super.key,
    required this.isLoading,
    required this.content,
    required this.state,
    required this.unusable
  });

  @override
  State<CouponElement> createState() => _CouponElementState();
}

class _CouponElementState extends State<CouponElement> {
  CouponLogo? _logo;

  @override
  Widget build(BuildContext context) {
    return createCouponElement();
  }

  Widget createCouponElement() {
    _logo ??= CouponLogo(
        couponId: widget.content["couponId"],
        currentLogoId: widget.content["logoId"]);
    var foregroundColor =
        widget.isLoading ? Colors.black : parseColor("couponForegroundColor");
    var backgroundColor =
        widget.isLoading ? Colors.white : parseColor("couponBackgroundColor");
    return FutureBuilder<dynamic>(
      future: _logo?.fetch(context),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return Skeletonizer(
          enabled: widget.isLoading,
          child: Container(
            width: 360,
            height: 130,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Opacity(
                          opacity: widget.unusable || hasExpired() ? 0.4 : 1,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: (_logo?.logo == null || widget.isLoading)
                                    ? Skeleton.leaf(
                                        child: Container(
                                          height: 75,
                                          width: 75,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 135,
                                          maxHeight: 75,
                                        ),
                                        child: _logo?.logo!,
                                      ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: widget.isLoading
                                    ? Skeleton.leaf(
                                        child: Container(
                                          width: 120,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        utf8.decode(widget
                                            .content["couponReward"]
                                            .toString()
                                            .codeUnits),
                                        style: TextStyle(
                                            color: foregroundColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: OutlinedButton(
                                  onPressed: () {
                                    if (widget.state ==
                                        CouponElementState.collectable) {
                                      collectCoupon(context);
                                    } else {
                                      redeemCoupon(context);
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    side: widget.isLoading
                                        ? BorderSide(width: 0)
                                        : BorderSide(
                                            color: foregroundColor,
                                            width: 2,
                                          ),
                                    foregroundColor: foregroundColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: LocaleText(widget.state ==
                                          CouponElementState.collectable
                                      ? "product.coupon.collect"
                                      : "product.coupon.redeem"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        !widget.isLoading &&
                                widget.state == CouponElementState.redeemable
                            ? CouponExpiration(
                                expiration: widget.content["expiration"])
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool hasExpired() {
    if (widget.isLoading || widget.state == CouponElementState.collectable) {
      return false;
    }
    return widget.content["expiration"] -
            DateTime.now().millisecondsSinceEpoch <=
        0;
  }

  Color parseColor(String key) {
    var hex = widget.content[key].toString();
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future<void> collectCoupon(context) async {
    if (widget.unusable) {
      return;
    }
    LoaderAlert().show(context);
    const storage = FlutterSecureStorage();
    var body = <String, Object>{"coupon": widget.content["couponId"]};
    final couponCache = await storage.read(key: "coupons");
    var coupons = (couponCache == null ? [] : jsonDecode(couponCache))
        .map((coupon) => coupon["redeemableId"])
        .toList();
    body["coupons"] = coupons;
    var response = await Request.post(url: "/user/coupon/collect/", body: body)
        .send(context);
    Navigator.pop(context);
    if (response == null || response.statusCode == 409) {
      ConnectionAlert().show(context);
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] == false) {
      displayCollectionError(context, responseBody["error"]);
      return;
    }
    collectionUpdateCouponCache(responseBody);
    checkIsNewPartner(responseBody);
    storeCouponCollection();
    Alert(
      description: "product.coupon.collect.successful",
      type: AlertType.success,
      callback: () {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductPage(initialPageIndex: 1),
          ),
          (route) => false,
        );
      },
    ).show(context);
  }

  Future<void> collectionUpdateCouponCache(responseBody) async {
    const storage = FlutterSecureStorage();
    final couponCache = await storage.read(key: "coupons");
    var coupons = couponCache == null ? [] : jsonDecode(couponCache);
    responseBody.remove("success");
    coupons.add(responseBody);
    await storage.write(key: "coupons", value: jsonEncode(coupons));
  }

  Future<void> storeCouponCollection() async {
    const storage = FlutterSecureStorage();
    final couponCache = await storage.read(key: "collectedCoupons");
    var coupons = couponCache == null ? [] : jsonDecode(couponCache);
    coupons.add(widget.content["couponId"]);
    await storage.write(key: "collectedCoupons", value: jsonEncode(coupons));
  }

  void displayCollectionError(context, error) {
    var description = "";
    if (error == 1000) {
      description = "product.coupon.collect.error.coupon.existence";
    } else if (error == 1001) {
      description = "product.coupon.collect.error.limitation";
    } else if (error == 1002) {
      description = "product.coupon.collect.error.already.collected";
    }
    Alert(
      description: description,
      type: AlertType.error,
    ).show(context);
    return;
  }

  Future<void> checkIsNewPartner(responseBody) async {
    const storage = FlutterSecureStorage();
    final partnerCache = await storage.read(key: "partners");
    var partners = partnerCache == null ? [] : jsonDecode(partnerCache);
    var partnerId = responseBody["partnerId"];
    if (!partners.contains(partnerId)) {
      partners.add(partnerId);
      await storage.write(key: "partners", value: jsonEncode(partners));
    }
    FirebaseMessaging.instance.subscribeToTopic(partnerId);
  }

  Future<void> redeemCoupon(context) async {
    if (widget.unusable || hasExpired()) {
      return;
    }
    ScanPopup(
      callback: (stamp, picc, cmac) =>
          completeCouponRedemption(context, stamp, picc, cmac),
    ).show(context, widget.key);
  }

  Future<void> completeCouponRedemption(context, stamp, picc, cmac) async {
    var redemption = CouponRedemption(
      coupon: widget.content["redeemableId"],
      stamp: stamp,
      picc: picc,
      cmac: cmac,
    );
    var redemptionResult = await redemption.redeemProcessed(context);
    if (!redemptionResult) {
      return;
    }
    ScanCooldown().enable();
    Navigator.pop(context);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProductPage(initialPageIndex: 1),
      ),
      (route) => false,
    );
    CouponRedemptionPopup(content: widget.content).show(context);
  }
}
