import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold,
    ),

    titleLarge: GoogleFonts.oswald(
      fontSize: 30,
      fontStyle: FontStyle.normal,
    ),

    bodyMedium: GoogleFonts.merriweather(),

    displaySmall: GoogleFonts.pacifico(),
  );
}