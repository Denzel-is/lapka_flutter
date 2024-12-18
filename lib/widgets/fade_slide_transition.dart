import 'package:flutter/material.dart';

class FadeSlideTransition extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  FadeSlideTransition({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Animation<double> fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval((index / 10), 1.0, curve: Curves.easeOut),
      ),
    );

    final Animation<Offset> slideAnimation = Tween(
      begin: Offset(0, 0.1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval((index / 10), 1.0, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}
