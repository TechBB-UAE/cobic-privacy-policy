import 'package:flutter/material.dart';

class NavigationHelper {
  /// Navigate to HomeScreen and clear all previous routes
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  /// Navigate to MainTabScreen with initial tab
  static void navigateToMainTab(BuildContext context, {int initialTab = 0}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/main',
      (route) => false,
    );
  }

  /// Navigate to LoginScreen
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  /// Pop current screen and return to previous screen
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Pop until specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  /// Push new route
  static Future<T?> pushNamed<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Push and replace current route
  static Future<T?> pushReplacementNamed<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushReplacementNamed<T, void>(routeName, arguments: arguments);
  }
} 