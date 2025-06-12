import 'package:flutter/material.dart';
import 'app_theme.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    Key? key,
    required String titleText,
    Color? backgroundColor,
    Color? iconColor,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    TextStyle? titleTextStyle,
  }) : super(
          key: key,
          title: Text(titleText, style: titleTextStyle),
          backgroundColor: backgroundColor,
          iconTheme: IconThemeData(color: iconColor ?? AppTheme.textColor),
          elevation: 0,
          surfaceTintColor: backgroundColor,
          centerTitle: centerTitle,
          actions: actions,
          leading: leading,
        );

  static PreferredSizeWidget themed({
    required BuildContext context,
    required String titleText,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return CustomAppBar(
      titleText: titleText,
      backgroundColor: isDark ? const Color(0xFF23242A) : Colors.white,
      iconColor: theme.iconTheme.color,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      titleTextStyle: theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
} 