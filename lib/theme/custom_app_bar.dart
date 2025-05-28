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
  }) : super(
          key: key,
          title: Text(titleText, style: const TextStyle(color: Colors.white)),
          backgroundColor: backgroundColor ?? AppTheme.lightTheme.appBarTheme.backgroundColor,
          iconTheme: IconThemeData(color: iconColor ?? Colors.white),
          elevation: 0,
          centerTitle: centerTitle,
          actions: actions,
          leading: leading,
        );
} 