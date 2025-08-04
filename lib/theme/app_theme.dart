import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
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
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFE1E1E1);
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);
  static const Color darkPrimaryColor = Color(0xFF2196F3);
  static const Color darkSecondaryColor = Color(0xFF424242);
  static const Color darkSecondaryBackground = Color(0xFF2C2C2C);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: appleBackground,
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
    cardTheme: const CardThemeData(
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
    dialogTheme: const DialogThemeData(
      backgroundColor: cardColor,
      titleTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
      contentTextStyle: TextStyle(color: textColor, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextColor),
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    cardTheme: const CardThemeData(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextColor, fontSize: 16),
      bodyMedium: TextStyle(color: darkTextColor, fontSize: 14),
      displayMedium: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 22),
      titleMedium: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkSecondaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkSecondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: darkSecondaryTextColor),
      hintStyle: const TextStyle(color: darkSecondaryTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextColor,
        side: BorderSide(color: darkPrimaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkTextColor),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkTextColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkTextColor),
      ),
    ),
    iconTheme: const IconThemeData(color: darkPrimaryColor),
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      background: darkBackground,
      surface: darkCardColor,
      onPrimary: Colors.white,
      onSecondary: darkTextColor,
      onBackground: darkTextColor,
      onSurface: darkTextColor,
      error: Colors.red,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkPrimaryColor,
      contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: darkCardColor,
      titleTextStyle: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 20),
      contentTextStyle: TextStyle(color: darkTextColor, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
  );
} 