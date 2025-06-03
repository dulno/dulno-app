import 'dart:math';

import 'package:dulno/product/base/page.dart';
import 'package:dulno/product/scan/scan_cooldown.dart';
import 'package:dulno/product/scan/scan_popup.dart';
import 'package:dulno/product/scan/stamp_redemption.dart';
import 'package:flutter/material.dart';

class ScanButton extends StatefulWidget {
  Function callback;
  Function currentPageIndex;

  ScanButton(
      {super.key, required this.callback, required this.currentPageIndex});

  @override
  State<ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<ScanButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double glowValue = sin(_controller.value * pi);
        return Container(
          height: 70,
          width: 70,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.6 * min(glowValue + 0.5, 1)),
                blurRadius: 15 * (glowValue + 0.5),
                spreadRadius: 4 * (glowValue + 0.5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              ScanPopup(
                callback: (stamp, picc, cmac) =>
                    redeemStamp(context, stamp, picc, cmac),
              ).show(context, widget.key);
            },
            backgroundColor:
                Color.lerp(Color(0xFF37479F), Color(0xFF495ED3), glowValue),
            shape: CircleBorder(),
            child: Image.asset('assets/images/logo-light.png', width: 55),
          ),
        );
      },
    );
  }

  Future<void> redeemStamp(context, stamp, picc, cmac) async {
    var redemption = StampRedemption(stamp: stamp, picc: picc, cmac: cmac);
    var redemptionResult = await redemption.redeemProcessed(context);
    if (!redemptionResult) {
      return;
    }
    ScanCooldown().enable();
    if (widget.currentPageIndex() == 0) {
      widget.callback();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ProductPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
