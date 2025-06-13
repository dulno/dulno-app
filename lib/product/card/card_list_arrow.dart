import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class CardListScanArrow extends StatefulWidget {
  const CardListScanArrow({super.key});

  @override
  State<CardListScanArrow> createState() => _CardListScanArrowState();
}

class _CardListScanArrowState extends State<CardListScanArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, _animation.value - 10),
                child: Transform(
                  transform: Matrix4.diagonal3Values(1, 1.25, 1),
                  alignment: Alignment.center,
                  child: Icon(CupertinoIcons.arrow_down,
                      size: 30, color: Colors.black),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -75),
                child: LocaleText("product.card.list.stamp.description"),
              ),
            ],
          );
        },
      ),
    );
  }
}
