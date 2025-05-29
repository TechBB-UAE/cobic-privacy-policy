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
          title: Text(titleText, style: const TextStyle(color: AppTheme.textColor)),
          backgroundColor: backgroundColor ?? Colors.white,
          iconTheme: IconThemeData(color: iconColor ?? AppTheme.textColor),
          elevation: 0,
          surfaceTintColor: Colors.white,
          centerTitle: centerTitle,
          actions: actions,
          leading: leading,
        );
} 