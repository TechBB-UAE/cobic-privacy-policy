import 'package:flutter/material.dart';

class AppTheme {
  static const Color appleBackground = Color(0xFFF5F5F7);
  static const Color appBarHomeColor = Colors.white;
  static const Color primaryColor = Color(0xFF0066CC); // xanh dương Apple style
  static const Color secondaryColor = Color(0xFFB8B5C6); // xám nhạt
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF22223B);
  static const Color secondaryTextColor = Color(0xFF6E6E7A);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color secondaryBackground = Color(0xFFE3F0FD); // nền xanh dương nhạt cho popup menu, nút user
  static const Color userButtonBackground = Color(0xFF2976D9); // màu xanh dương đậm cho button user và popup
  
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: appleBackground,
    backgroundColor: appleBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: appleBackground,
      foregroundColor: textColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    cardTheme: const CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
      titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: secondaryTextColor),
      hintStyle: const TextStyle(color: secondaryTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
      ),
    ),
    iconTheme: const IconThemeData(color: primaryColor),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: appleBackground,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: textColor,
      onBackground: textColor,
      onSurface: textColor,
      error: Colors.red,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: cardColor,
      titleTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
      contentTextStyle: TextStyle(color: textColor, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
  );

  static ThemeData darkTheme = lightTheme;
} 