import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Center(
        child: Image.asset(
          'assets/images/splashscreen.gif',
          width: 260,
          height: 260,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
} 