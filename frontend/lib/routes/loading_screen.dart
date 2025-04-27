import 'dart:ui';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {

  static const double BLUR_SIGMA_X = 5.0;
  static const double BLUR_SIGMA_Y = 5.0;
  static const double BACKGROUND_OPACITY = 0.5;
  static const double LOGO_WIDTH = 150.0;
  static const double SPACER_HEIGHT = 20.0;
  static const Color LOADER_COLOR = Color(0xFF6E44FF);

  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: BLUR_SIGMA_X,
          sigmaY: BLUR_SIGMA_Y,
        ),
        child: Container(
          color: Colors.black.withOpacity(BACKGROUND_OPACITY),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/assets/logo.png', width: LOGO_WIDTH),
                const SizedBox(height: SPACER_HEIGHT),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(LOADER_COLOR),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}