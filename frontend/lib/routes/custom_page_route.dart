import 'package:flutter/cupertino.dart';
import 'package:zadachok/routes/transitions.dart';

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final int currentIndex;
  final int previousIndex;
  final TransitionType transitionType;

  CustomPageRoute({
    required this.child,
    required this.currentIndex,
    required this.previousIndex,
    this.transitionType = TransitionType.slide,
  }) : super(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case TransitionType.fade:
          return CustomRouteTransitions.fadeTransition(child, animation);
        case TransitionType.slide:
          return CustomRouteTransitions.slideTransition(
              child, animation, currentIndex, previousIndex);
        case TransitionType.scale:
          return CustomRouteTransitions.scaleTransition(child, animation);
        case TransitionType.combined:
          return CustomRouteTransitions.combinedSlideFadeTransition(
              child, animation, currentIndex, previousIndex);
        case TransitionType.cube:
          return CustomRouteTransitions.cubeTransition(child, animation);
        case TransitionType.zoom:
          return CustomRouteTransitions.zoomTransition(child, animation);
        case TransitionType.parallax:
          return CustomRouteTransitions.parallaxTransition(
              child, animation, currentIndex, previousIndex);
      }
    },
  );
}

enum TransitionType {
  fade,
  slide,
  scale,
  combined,
  cube,
  zoom,
  parallax,
}