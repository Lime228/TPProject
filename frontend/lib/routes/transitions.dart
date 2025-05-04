import 'package:flutter/material.dart';

class CustomRouteTransitions {

  static const double SLIDE_BEGIN_OFFSET = 1.0;
  static const double SLIDE_END_OFFSET = 0.0;
  static const double SCALE_BEGIN = 0.5;
  static const double SCALE_END = 1.0;
  static const double COMBINED_SLIDE_OFFSET = 0.5;
  static const Curve ANIMATION_CURVE = Curves.easeInOut;
  static const Curve SCALE_CURVE = Curves.easeOutBack;
  static const Color MATERIAL_COLOR = Colors.white;

  static Widget slideTransition(
      Widget child,
      Animation<double> animation,
      int currentIndex,
      int previousIndex
      ) {
    final offsetAnimation = Tween<Offset>(
      begin: Offset(
          currentIndex > previousIndex ? SLIDE_BEGIN_OFFSET : -SLIDE_BEGIN_OFFSET,
          SLIDE_END_OFFSET
      ),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ANIMATION_CURVE,
    ));

    return Material(
      color: MATERIAL_COLOR,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }

  static Widget fadeTransition(Widget child, Animation<double> animation) {
    return Material(
      color: MATERIAL_COLOR,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static Widget scaleTransition(Widget child, Animation<double> animation) {
    return Material(
      color: MATERIAL_COLOR,
      child: ScaleTransition(
        scale: Tween<double>(begin: SCALE_BEGIN, end: SCALE_END).animate(
          CurvedAnimation(
            parent: animation,
            curve: SCALE_CURVE,
          ),
        ),
        child: child,
      ),
    );
  }

  static Widget combinedTransition(
      Widget child,
      Animation<double> animation,
      int currentIndex,
      int previousIndex
      ) {
    final offsetAnimation = Tween<Offset>(
      begin: Offset(
          currentIndex > previousIndex ? COMBINED_SLIDE_OFFSET : -COMBINED_SLIDE_OFFSET,
          SLIDE_END_OFFSET
      ),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ANIMATION_CURVE,
    ));

    return Material(
      color: MATERIAL_COLOR,
      child: SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}