import 'package:dulno/product/coupon/coupon_animation.dart';
import 'package:dulno/product/coupon/coupon_logo.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CouponElement extends StatefulWidget {
  final bool isLoading;
  final Map<String, dynamic> content;
  final bool animateLastStamp;
  final bool animateCoupon;

  const CouponElement(
      {super.key,
      required this.isLoading,
      required this.content,
      required this.animateLastStamp,
      required this.animateCoupon});

  @override
  State<CouponElement> createState() => _CouponElementState();
}

class _CouponElementState extends State<CouponElement> {
  CouponLogo? _logo;

  @override
  Widget build(BuildContext context) {
    var element = createCouponElement();
    if (widget.animateCoupon) {
      return CouponBlinkerAnimation(
        child: element,
        color: Colors.grey[400]!,
        scale: 1.05,
      );
    }
    return element;
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
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: (_logo?.logo == null || widget.isLoading)
                            ? Skeleton.leaf(
                                child: Container(
                                  height: 75,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(25),
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
                      widget.isLoading
                          ? Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(top: 100),
                              child: Skeleton.leaf(
                                child: Container(
                                  width: double.infinity,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    // This helps even in non-skeleton mode
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            )
                          : createCouponContent(foregroundColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget createCouponContent(foregroundColor) {
    return Container();
  }

  Color parseColor(String key) {
    var hex = widget.content[key].toString();
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
