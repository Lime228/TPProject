import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zadachok/routes/main_navigation.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoSlide;

  late AnimationController _textController;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();


    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack)),
    );

    _logoSlide = Tween<double>(begin: 0.0, end: -152.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    await _textController.reverse();
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _logoController,
        builder: (context, child) {
          return Center(
            child: Transform.translate(
              offset: Offset(0, _logoSlide.value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: _logoScale.value,
                    child: Image.asset(
                      'lib/assets/logo.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _textOpacity,
                    child: const Text(
                      'ZadachOk',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
