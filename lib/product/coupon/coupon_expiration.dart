import 'dart:math';

import 'package:dulno/localization/locales.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CouponExpiration extends StatelessWidget {
  final int expiration;

  const CouponExpiration({super.key, required this.expiration});

  @override
  Widget build(BuildContext context) {
    if (expiration == -1) {
      return SizedBox();
    }
    var remaining = max(0, expiration - DateTime.now().millisecondsSinceEpoch);
    var lessThanDay = remaining < 1000 * 60 * 60 * 24;
    return Positioned(
      top: -20,
      left: -20,
      child: Container(
        decoration: BoxDecoration(
          color: remaining == 0
              ? Colors.grey[400]
              : lessThanDay
                  ? Colors.redAccent
                  : Colors.yellow,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.hourglass,
              color: lessThanDay && remaining > 0 ? Colors.white : Colors.black,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              formatTime(context, remaining),
              style: TextStyle(
                color:
                    lessThanDay && remaining > 0 ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatTime(context, remaining) {
    if (remaining == 0) {
      return Locales.string(context, "product.coupon.expiration.expired");
    }
    if (remaining > 1000 * 60 * 60 * 24) {
      return (remaining / (1000 * 60 * 60 * 24)).ceil().toString() +
          " " +
          Locales.string(context, "product.coupon.expiration.unit.day");
    }
    return (remaining / (1000 * 60 * 60)).ceil().toString() +
        " " +
        Locales.string(context, "product.coupon.expiration.unit.hour");
  }
}
