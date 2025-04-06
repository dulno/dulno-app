import 'dart:math';

import 'package:dulno/product/base/scan_popup.dart';
import 'package:flutter/material.dart';

class ProductScanButton extends StatefulWidget {
  const ProductScanButton({super.key});

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
                color: Colors.blue.withOpacity(0.6 * min(glowValue + 0.5, 1)),
                blurRadius: 20 * (glowValue + 0.5),
                spreadRadius: 5 * (glowValue + 0.5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              _showNfcPopup(context);
            },
            backgroundColor:
                Color.lerp(Color(0xFF316DBC), Color(0xFF207EFA), glowValue),
            shape: CircleBorder(),
            child: Image.asset('assets/images/logo-light.png', width: 65),
          ),
        );
      },
    );
  }

  void _showNfcPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close when tapping outside
          },
          behavior: HitTestBehavior.opaque, // Ensures tap detection outside the child
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevents closing when tapping inside
              behavior: HitTestBehavior.translucent, // Ensures touch events inside are not blocked
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                margin: EdgeInsets.only(bottom: 30),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ProductNFCScanPopup(),
              ),
            ),
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
