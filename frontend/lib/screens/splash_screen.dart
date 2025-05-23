import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/routes/main_navigation.dart';

import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration LOGO_ANIMATION_DURATION = Duration(milliseconds: 2000);
  static const Duration TEXT_ANIMATION_DURATION = Duration(milliseconds: 800);
  static const double LOGO_SIZE = 150.0;
  static const double TEXT_FONT_SIZE = 28.0;

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoSlide;
  late AnimationController _textController;
  late Animation<double> _textOpacity;

  Future<void> _initializeAndAnimate() async {
    await _initializeApp();
    _startAnimation();
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeAndAnimate();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: LOGO_ANIMATION_DURATION,
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      ),
    );

    _logoSlide = Tween<double>(begin: 0.0, end: -152.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _textController = AnimationController(
      duration: TEXT_ANIMATION_DURATION,
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuth();

    final groupProvider = authProvider.groupProvider;
    await groupProvider.loadGroupData();
  }

  Future<void> _startAnimation() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    await _textController.reverse();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
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
                    child: SvgPicture.asset(
                      'lib/assets/logo.svg',
                      width: LOGO_SIZE,
                      height: LOGO_SIZE,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _textOpacity,
                    child: const Text(
                      'ZadachOk',
                      style: TextStyle(
                        fontSize: TEXT_FONT_SIZE,
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

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }
}