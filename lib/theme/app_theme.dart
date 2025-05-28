import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryColor = Color(0xFFB266FF);
  static const Color _secondaryColor = Color(0xFF8F5AFF);
  static const Color _errorColor = Color(0xFFE53935);
  static const Color _successColor = Color(0xFF43A047);
  static const Color _warningColor = Color(0xFFFFA000);
  
  // Purple background đậm cho cả 2 mode
  static const Color _backgroundColor = Color(0xFF2D1457);
  static const Color _surfaceColor = Color(0xFF2D1457);
  static const Color _textColor = Colors.white;
  static const Color _secondaryTextColor = Color(0xFFE1CFFF);
  
  // Text Styles
  static const String _fontFamily = 'Roboto';

  // Button Styles
  static final ButtonStyle _primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: _primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _textButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static final ButtonStyle _errorButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: _errorColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _successButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: _successColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _warningButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: _warningColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      background: _backgroundColor,
      surface: _surfaceColor,
      error: _errorColor,
    ),
    scaffoldBackgroundColor: _backgroundColor,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _textColor,
        fontFamily: _fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _textColor,
        fontFamily: _fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _textColor,
        fontFamily: _fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: _textColor,
        fontFamily: _fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: _secondaryTextColor,
        fontFamily: _fontFamily,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _secondaryButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: _textButtonStyle,
    ),
    cardTheme: CardTheme(
      color: _surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      labelStyle: const TextStyle(color: _textColor),
      hintStyle: const TextStyle(color: _secondaryTextColor),
      prefixIconColor: _textColor,
      suffixIconColor: _textColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _textColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _textColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
    ),
    iconTheme: const IconThemeData(
      color: _primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A0742),
      foregroundColor: _textColor,
      elevation: 0,
      iconTheme: IconThemeData(color: _textColor),
      titleTextStyle: TextStyle(
        color: _textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: _fontFamily,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      background: _backgroundColor,
      surface: _surfaceColor,
      error: _errorColor,
    ),
    scaffoldBackgroundColor: _backgroundColor,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _textColor,
        fontFamily: _fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _textColor,
        fontFamily: _fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _textColor,
        fontFamily: _fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: _textColor,
        fontFamily: _fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: _secondaryTextColor,
        fontFamily: _fontFamily,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _secondaryButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: _textButtonStyle,
    ),
    cardTheme: CardTheme(
      color: _surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _secondaryTextColor),
      ),
    ),
    iconTheme: const IconThemeData(
      color: _primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _backgroundColor,
      foregroundColor: _textColor,
      elevation: 0,
      iconTheme: IconThemeData(color: _textColor),
      titleTextStyle: TextStyle(
        color: _textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: _fontFamily,
      ),
    ),
  );

  // Các style button đặc biệt
  static ButtonStyle get errorButtonStyle => _errorButtonStyle;
  static ButtonStyle get successButtonStyle => _successButtonStyle;
  static ButtonStyle get warningButtonStyle => _warningButtonStyle;

  // Hàm trả về style OutlinedButton chuẩn từ theme
  static ButtonStyle? outlinedButtonTheme(BuildContext context) {
    return Theme.of(context).outlinedButtonTheme.style;
  }

  static const Color secondaryTextColor = _secondaryTextColor;
  static const Color textColor = _textColor;
  static const Color successColor = _successColor;
} 