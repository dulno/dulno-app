import 'package:dulno/product/base/page_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CouponListBody extends ProductPageBody {
  final GlobalKey<_CouponListBodyContentState> _key =
  GlobalKey<_CouponListBodyContentState>();

  CouponListBody({super.key})
      : super(name: "product.coupon.list.label",  unselectedIcon: CupertinoIcons.gift,
      selectedIcon: CupertinoIcons.gift_fill);

  @override
  Widget content(BuildContext context) {
    return CouponListBodyContent(key: _key);
  }
}

class CouponListBodyContent extends StatefulWidget {
  const CouponListBodyContent({super.key});

  @override
  State<CouponListBodyContent> createState() =>
      _CouponListBodyContentState();
}

class _CouponListBodyContentState extends State<CouponListBodyContent> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
