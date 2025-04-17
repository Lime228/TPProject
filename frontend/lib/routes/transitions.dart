import 'package:flutter/material.dart';

class CustomRouteTransitions {
  static Widget slideTransition(Widget child, Animation<double> animation, int currentIndex, int previousIndex) {
    final offsetAnimation = Tween<Offset>(
      begin: Offset(currentIndex > previousIndex ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    return Material(
      color: Colors.white,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }

  static Widget fadeTransition(Widget child, Animation<double> animation) {
    return Material(
      color: Colors.white,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static Widget scaleTransition(Widget child, Animation<double> animation) {
    return Material(
      color: Colors.white,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
        ),
        child: child,
      ),
    );
  }

  static Widget combinedTransition(Widget child, Animation<double> animation, int currentIndex, int previousIndex) {
    final offsetAnimation = Tween<Offset>(
      begin: Offset(currentIndex > previousIndex ? 0.5 : -0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    return Material(
      color: Colors.white,
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