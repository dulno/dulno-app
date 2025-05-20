import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CouponBlinkerAnimation extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;
  final int repeatCount;
  final double scale;
  final double blurRadius;

  const CouponBlinkerAnimation({
    super.key,
    required this.child,
    required this.color,
    this.duration = const Duration(milliseconds: 300),
    this.repeatCount = 3,
    this.scale = 1.2,
    this.blurRadius = 20,
  });

  @override
  State<CouponBlinkerAnimation> createState() => _CouponBlinkerAnimationState();
}

class _CouponBlinkerAnimationState extends State<CouponBlinkerAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glowOpacity;

  int _completed = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scale = Tween(begin: 1.0, end: widget.scale).animate(curvedAnimation);
    _glowOpacity = Tween(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completed++;
        if (_completed < widget.repeatCount) {
          _controller.reverse();
        } else {
          _controller.reverse();
        }
      } else if (status == AnimationStatus.dismissed) {
        if (_completed < widget.repeatCount) {
          _controller.forward();
        }
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_glowOpacity.value),
                  blurRadius: widget.blurRadius,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
