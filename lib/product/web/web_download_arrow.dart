import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WebDownloadArrow extends StatefulWidget {
  const WebDownloadArrow({super.key});

  @override
  State<WebDownloadArrow> createState() => _WebDownloadArrowState();
}

class _WebDownloadArrowState extends State<WebDownloadArrow>
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

    _animation = Tween<double>(begin: 0, end: -16).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value + 8, 0),
          child: Transform(
            transform: Matrix4.diagonal3Values(1.25, 1, 1),
            alignment: Alignment.center,
            child:
                Icon(CupertinoIcons.arrow_right, size: 30, color: Colors.black),
          ),
        );
      },
    );
  }
}
