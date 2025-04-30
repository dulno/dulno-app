import 'dart:io';
import 'dart:math';

import 'package:dulno/product/base/android_scan_popup.dart';
import 'package:dulno/product/base/ios_scan_popup.dart';
import 'package:flutter/material.dart';

class ProductScanButton extends StatefulWidget {
  Function callback;
  Function currentPageIndex;

  ProductScanButton(
      {super.key, required this.callback, required this.currentPageIndex});

  @override
  State<ProductScanButton> createState() => _ProductScanButtonState();
}

class _ProductScanButtonState extends State<ProductScanButton>
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
          height: 90,
          width: 90,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.6 * min(glowValue + 0.5, 1)),
                blurRadius: 20 * (glowValue + 0.5),
                spreadRadius: 5 * (glowValue + 0.5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              if (Platform.isAndroid) {
                ProductNFCScanPopup(
                  callback: widget.callback,
                  currentPageIndex: widget.currentPageIndex,
                ).show(context, widget.key);
                return;
              }
              ProductIOSNFCScanPopup(
                callback: widget.callback,
                currentPageIndex: widget.currentPageIndex,
              ).show(context, widget.key);
            },
            backgroundColor:
                Color.lerp(Color(0xFF37479F), Color(0xFF495ED3), glowValue),
            shape: CircleBorder(),
            child: Image.asset('assets/images/logo-light.png', width: 65),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
