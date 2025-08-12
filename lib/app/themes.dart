import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF007AFF),
    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
    fontFamily: GoogleFonts.inter().fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFF333333),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
      bodySmall: GoogleFonts.inter(color: Colors.grey.shade600),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007AFF),
      secondary: Color(0xFF007AFF),
      surface: Color(0xFFF7F7F7),
    ).copyWith(surface: const Color(0xFFF7F7F7)),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF007AFF),
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: GoogleFonts.inter().fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFFE0E0E0),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFE0E0E0)),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFFE0E0E0)),
      bodySmall: GoogleFonts.inter(color: Colors.grey.shade400),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF007AFF),
      secondary: Color(0xFF007AFF),
      surface: Color(0xFF121212),
    ).copyWith(surface: const Color(0xFF121212)),
  );
}
