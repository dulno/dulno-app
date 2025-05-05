import 'dart:math';

import 'package:dulno/product/scan/scan_popup_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';

class IOSScanPopupContent extends ScanPopupContent {
  const IOSScanPopupContent(
      {super.key, required super.callback, required super.currentPageIndex});

  @override
  State<IOSScanPopupContent> createState() => IOSScanPopupContentState();
}

class IOSScanPopupContentState
    extends ScanPopupContentState<IOSScanPopupContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int arrowCount = 5;
  final double amplitude = 8;
  final double frequency = 2 * pi;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  Future<void> checkNFC(context) async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      widget.readNFCTag(
        context: context,
        readCallback: () {
          HapticFeedback.vibrate();
        },
      );
    } else {
      widget.displayNFCTagUnsupportedError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(top: 75),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            double t = _controller.value; // [0.0, 1.0]
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(arrowCount, (index) {
                double offsetY = sin(t * frequency) * amplitude;
                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Transform.scale(
                        scaleY: 1.2,
                        child: Icon(Icons.arrow_upward_rounded,
                            size: 50, color: Colors.white),
                      )),
                );
              }),
            );
          },
        ));
  }
}
