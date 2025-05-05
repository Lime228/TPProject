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


  static Widget fadeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }


  static Widget slideTransition(
      Widget child,
      Animation<double> animation,
      int currentIndex,
      int previousIndex,
      ) {
    final offsetAnimation = Tween<Offset>(
      begin: Offset(
        currentIndex > previousIndex ? SLIDE_BEGIN_OFFSET : -SLIDE_BEGIN_OFFSET,
        SLIDE_END_OFFSET,
      ),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ANIMATION_CURVE,
    ));

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }


  static Widget scaleTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: SCALE_BEGIN, end: SCALE_END).animate(
        CurvedAnimation(
          parent: animation,
          curve: SCALE_CURVE,
        ),
      ),
      child: child,
    );
  }


  static Widget combinedSlideFadeTransition(
      Widget child,
      Animation<double> animation,
      int currentIndex,
      int previousIndex,
      ) {
    final offsetAnimation = Tween<Offset>(
      begin: Offset(
        currentIndex > previousIndex ? COMBINED_SLIDE_OFFSET : -COMBINED_SLIDE_OFFSET,
        SLIDE_END_OFFSET,
      ),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ANIMATION_CURVE,
    ));

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }


  static Widget cubeTransition(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * (3.141592 / 2);
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.centerRight,
          child: child,
        );
      },
      child: child,
    );
  }


  static Widget zoomTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }


  static Widget parallaxTransition(
      Widget child,
      Animation<double> animation,
      int currentIndex,
      int previousIndex,
      ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(
          currentIndex > previousIndex ? 0.3 : -0.3,
          0,
        ),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      )),
      child: child,
    );
  }
}
