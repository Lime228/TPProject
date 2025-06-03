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
  static const Duration TEXT_ANIMATION_DURATION = Duration(milliseconds: 400);
  static const Duration TRANSITION_DURATION = Duration(milliseconds: 50);
  static const double LOGO_SIZE = 150.0;
  static const double TEXT_FONT_SIZE = 40.0;

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoSlide;
  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

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

    // Логотип появляется с масштабированием и небольшим вращением
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Логотип поднимается вверх с "пружинным" эффектом
    _logoSlide = Tween<double>(begin: 0.0, end: -152.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutBack),
      ),
    );

    _textController = AnimationController(
      duration: TEXT_ANIMATION_DURATION,
      vsync: this,
    );

    // Текст появляется с прозрачностью и небольшим скольжением снизу
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeInOut,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuth();

    if (authProvider.token!=null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Автоматический вход выполнен',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF937DF3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    final groupProvider = authProvider.groupProvider;
    await groupProvider.loadGroupData();
  }

  Future<void> _startAnimation() async {
    // Запускаем анимацию логотипа
    await _logoController.forward();

    // Небольшая пауза перед появлением текста
    await Future.delayed(const Duration(milliseconds: 300));

    // Запускаем анимацию текста
    await _textController.forward();

    // Пауза для демонстрации
    await Future.delayed(const Duration(milliseconds: 1500));

    // Плавное исчезновение текста
    await _textController.reverse();

    // Финальная пауза перед переходом
    await Future.delayed(TRANSITION_DURATION);

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
        animation: Listenable.merge([_logoController, _textController]),
        builder: (context, child) {
          return Center(
            child: Transform.translate(
              offset: Offset(0, _logoSlide.value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform(
                    transform: Matrix4.identity()
                      ..scale(_logoScale.value)
                      ..rotateZ(_logoRotation.value),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'lib/assets/logo.svg',
                      width: LOGO_SIZE,
                      height: LOGO_SIZE,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: const Text(
                        'ZадачOk',
                        style: TextStyle(
                          fontSize: TEXT_FONT_SIZE,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: Color(0xFF937DF3)
                        ),
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