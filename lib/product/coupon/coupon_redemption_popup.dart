import 'dart:convert';

import 'package:dulno/alert/alert.dart';
import 'package:dulno/localization/locale_text.dart';
import 'package:dulno/product/base/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CouponRedemptionPopup {
  final Map<String, dynamic> content;

  CouponRedemptionPopup({required this.content});

  show(context) {
    Alert(
      content: createContent(context),
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

  Widget createContent(context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            utf8.decode(content["couponReward"].toString().codeUnits),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 30,
          ),
          LocaleText("product.coupon.redeem.successful")
        ],
      ),
    );
  }
}
