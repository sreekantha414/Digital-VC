import 'package:flutter/material.dart';

class AppColors {
  static const cream = Color(0xFFFFF9F0);
  static const lightPurple = Color(0xFFB39DDB);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const darkPurple = Color(0xFF9575CD);
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.lightPurple,
  scaffoldBackgroundColor: AppColors.cream,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightPurple,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: AppColors.lightPurple),
);
