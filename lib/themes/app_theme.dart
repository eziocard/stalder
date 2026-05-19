import 'package:flutter/material.dart';
import 'package:stalder/themes/app_text_theme.dart';

class AppTheme {

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),

    textTheme: AppTextTheme.darkTextTheme,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),

    textTheme: AppTextTheme.darkTextTheme,
  );
}